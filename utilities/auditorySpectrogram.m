function varargout = auditorySpectrogram(x,fs,varargin)
%AUDITORYSPECTROGRAM Spectrogram using auditory scales
%
%   THIS IS AN EXAMPLE FUNCTION AND MAY CHANGE IN A FUTURE RELEASE.
%
%   S = auditorySpectrogram(x,fs) returns a mel-spaced auditory spectrogram
%   using default properties. x must be a single channel (column vector) of
%   type double or single. fs must be a real positive scalar of type double
%   or single.
%
%   S = auditorySpectrogram(...,'WindowLength',WINDOWLENGTH) specifies the
%   analysis window length. Specify the window length in samples as a
%   positive scalar. If unspecified, WINDOWLENGTH defaults to
%   round(fs.*0.030).
%
%   S = auditorySpectrogram(...,'OverlapLength',OVERLAPLENGTH) specifies
%   the number of samples overlap between adjacent windows. Specify the
%   overlap length as a positive scalar smaller than the window length. If
%   unspecified, OVERLAPLENGTH defaults to round(fs*0.02).
%
%   S = auditorySpectrogram(...,'NumBands',NUMBANDS) specifies the number
%   of bandpass filters used. If unspecified, NUMBANDS defaults to 40.
%
%   S = auditorySpectrogram(...,'FFTLength',FFTLENGTH) specifies the number
%   of points in the DFT. If unspecified, FFTLENGTH defaults to 512.
%
%   S = auditorySpectrogram(...,'Range',RANGE) specifies the start and end
%   of the bandpass filters. If unspecified, RANGE defaults to
%   [0,floor(fs/2)].
%
%   S = auditorySpectrogram(...,'WindowType',WINDOWTYPE) specifies the
%   window type applied before taking the FFT. Specify WINDOWTYPE as
%   'Hann','Hamming', or 'Rectangular'. If unspecified, WINDOWTYPE defaults
%   to 'Hamming'.
%
%   S = auditorySpectrogram(...,'SumExponent',SUMEXPONENT) specifies the
%   exponent of the frequency domain.
%
%   S = auditorySpectrogram(...,'FilterBankNormalization',FILTERBANKNORMALIZATION)
%   specifies the type of filter bank nomalization. Specify
%   FILTERBANKNORMALIZATION as 'Area', 'Bandwidth', or 'None'. If
%   unspecified, FILTERBANKNORMALIZATION defaults to 'Bandwidth'.
%
%   S = auditorySpectrogram(...,'FilterBankDesignDomain',FILTERBANKDESIGNDOMAIN)
%   specifies the filter bank design domain. Specify FILTERBANKDESIGNDOMAIN
%   as 'Bin' or 'Hertz'. The default is 'Bin'.
%
%   S = auditorySpectrogram(...,'WarpType',WARPTYPE) specifies the warping
%   algorithm for the filter bank bandedges. Specify WARPTYPE as
%   'Bark','ERB', or 'Mel'. If unspecified, WARPTYPE defaults to 'Mel'.
%
%   auditorySpectrogram(...) plots the spectrogram.
%
%   %EXAMPLE 1: Plot the Auditory Spectrogram of a Voice File
%     [audio,fs] = audioread('Counting-16-44p1-mono-15secs.wav');
%     auditorySpectrogram(audio,fs)
%
% See also CEPSTRALFEATUREEXTRACTOR, MFCC, VOICEACTIVITYDETECTOR, PITCH

% Copyright 2017 The Mathworks, Inc.

persistent pFilterBank pWindow pPreallocation pIdx % Used to cache designed parameters for speed
persistent previousParams previousFrameSize % Used to determine if redesign is necessary

% Parse and validate inputs -----------------------------------------------
validateRequiredInputs(x,fs)
userInput = parseInputs(x,fs,varargin{:});

nRow = size(x,1);
validateOptionalInputs(fs,nRow,userInput)
params = setParams(userInput,fs,class(x));
% -------------------------------------------------------------------------

% Design Filterbank, window, and preallocate ------------------------------
if ~isequal(params,previousParams) || ~isequal(nRow,previousFrameSize)
    if ~isequal(params,previousParams)
        switch params.WarpType
            case 'Bark'
                range     = hz2bark(params.Range);
                bandEdges = bark2hz(linspace(range(1),range(end),params.NumBands+2));
            case 'ERB'
                range     = hz2erb(params.Range);
                bandEdges = erb2hz(linspace(range(1),range(end),params.NumBands+2));
            otherwise %Mel
                range     = hz2mel(params.Range);
                bandEdges = mel2hz(linspace(range(1),range(end),params.NumBands+2));
        end
        pFilterBank = audio.internal.designAuditoryFilterBank(params.SampleRate, ...
            bandEdges, ...
            params.FFTLength, ...
            params.SumExponent, ...
            params.FilterBankNormalization, ...
            params.FilterBankDesignDomain, ...
            params.Datatype);
        pFilterBank = pFilterBank';
    end
    
    numHops = fix((nRow-params.WindowLength)/params.HopLength) + 1;
    
    win = dsp.private.designWindow(params.WindowType,params.WindowLength,params.Datatype);
    pWindow = repmat(win,1,numHops);
    
    pPreallocation = zeros(params.NumBands,numHops,'like',x);
    
    % Determine indices for reshaping
    overlap    = params.WindowLength - params.HopLength;
    ncol       = fix((nRow-overlap)/(params.HopLength));
    coloffsets = (0:(ncol-1))*(params.HopLength);
    pIdx   = (1:params.WindowLength)'+coloffsets;
    
    previousParams = params;
    previousFrameSize = nRow;
end
% -------------------------------------------------------------------------

% MAIN PROCESSING ---------------------------------------------------------
% Window and convert to magnitude frequency domain
AA = abs(fft(x(pIdx).*pWindow,params.FFTLength));

% Apply filter bank
for hop = 1:size(pWindow,2)
    pPreallocation(:,hop) = pFilterBank*AA(:,hop);
end
% -------------------------------------------------------------------------

% Output ------------------------------------------------------------------
if nargout~=0
    [varargout{1:nargout}] = pPreallocation;
else
    hpc = pcolor(log10(pPreallocation));
    hpc.EdgeColor = 'none';
end
% -------------------------------------------------------------------------
end


% -------------------------------------------------------------------------
% Parse inputs
% -------------------------------------------------------------------------
function userInput = parseInputs(x,fs,varargin)
    persistent parser designfs
    designParser = false;
    if isempty(parser)
        designParser = true;
    else
        if designfs ~= fs
            designParser = true;
        end
    end
    if designParser == true
        parser                 = inputParser;
        parser.PartialMatching = false;
        parser.FunctionName    = 'auditorySpectrogram';

        addRequired(parser,'x');
        addRequired(parser,'fs');
        defaults = getDefaultParameters(fs);
        designfs = fs;
        addOptional(parser,'WindowLength',              defaults.WindowLength);
        addOptional(parser,'OverlapLength',             defaults.OverlapLength);
        addOptional(parser,'NumBands',                  defaults.NumBands);
        addOptional(parser,'FFTLength',                 defaults.FFTLength);
        addOptional(parser,'Range',                     defaults.Range);
        addOptional(parser,'WindowType',                defaults.WindowType);
        addOptional(parser,'SumExponent',               defaults.SumExponent);
        addOptional(parser,'FilterBankNormalization',   defaults.FilterBankNormalization);
        addOptional(parser,'FilterBankDesignDomain',    defaults.FilterBankDesignDomain);
        addOptional(parser,'WarpType',                  defaults.WarpType);
    end

    parse(parser,x,fs,varargin{:});
    userInput = parser.Results;
end

% -------------------------------------------------------------------------
% Default parameter values
% -------------------------------------------------------------------------
function defaults = getDefaultParameters(fs)
defaults = struct( ...
    'WindowLength',             round(fs.*0.030),...
    'OverlapLength',            round(fs*0.02), ...
    'NumBands',                 40, ...
    'FFTLength',                512, ...
    'Range',                    [0,floor(fs/2)], ...
    'WindowType',               'Hamming', ...
    'SumExponent',              2, ...
    'FilterBankNormalization',  'Bandwidth', ...
    'FilterBankDesignDomain',   'Hz', ...
    'WarpType',                 'Mel');
end

% -------------------------------------------------------------------------
% Validate required inputs
% -------------------------------------------------------------------------
function validateRequiredInputs(x,fs)
validateattributes(x,{'single','double'},...
    {'nonempty','column','real'}, ...
    'auditorySpectrogram','audioIn')
validateattributes(fs,{'single','double'}, ...
    {'nonempty','positive','real','scalar','nonnan','finite'}, ...
    'auditorySpectrogram','fs');
end

% -------------------------------------------------------------------------
% Validate optional input
% -------------------------------------------------------------------------
function validateOptionalInputs(fs,N,userInput)

if(userInput.WindowLength < 2) || (userInput.WindowLength > N)
   error(['Window length must in the range [2,size(x,1)], ' , ...
          'where x is the input to auditorySpectrogram function.\n', ...
          'The default window length is round(fs*0.03)']);
end
validateattributes(userInput.WindowLength,{'single','double'}, ...
    {'nonempty','integer','scalar','real'}, ...
    'auditorySpectrogram','WindowLength');
validateattributes(userInput.OverlapLength,{'single','double'}, ...
    {'nonempty','integer','scalar','real'}, ...
    'auditorySpectrogram','OverlapLength');
if userInput.OverlapLength>=userInput.WindowLength
    error(['Specify overlap length as less than or equal to window length.\n', ...
        'The default window length is round(fs*0.03). The default overlap length is round(fs*0.02)']);
end

validatestring(userInput.WindowType,{'Hann','Hamming','Rectangular'});
validateattributes(userInput.Range,{'single','double'}, ...
    {'nonempty','increasing','nonnegative','row','ncols',2,'real'}, ...
    'auditorySpectrogram','Range')
if userInput.Range(1)<0 || userInput.Range(2)>fs
    error('Specify range as a 2-element row vector in the range [0,fs]')
end

validateattributes(userInput.SumExponent,{'single','double'}, ...
    {'nonempty','scalar','real'}, ...
    'auditorySpectrogram','SumExponent');
validatestring(userInput.FilterBankNormalization,{'Area','Bandwidth'});
validatestring(userInput.FilterBankDesignDomain,{'Bin','Hz'});
validatestring(userInput.WarpType,{'Mel','Bark','Log','ERB'});

end

% -------------------------------------------------------------------------
% Set parameters based on user input
% -------------------------------------------------------------------------
function params = setParams(userInput,fs,dt)
params.Datatype                = dt;
params.SampleRate              = fs;
params.WindowLength            = userInput.WindowLength;
params.HopLength               = userInput.WindowLength - userInput.OverlapLength;
params.NumBands                = userInput.NumBands;
params.FFTLength               = userInput.FFTLength;
params.DeltaWindowLength       = userInput.WindowType;
params.Range                   = userInput.Range;
params.SumExponent             = userInput.SumExponent;
params.FilterBankNormalization = userInput.FilterBankNormalization;
params.FilterBankDesignDomain  = userInput.FilterBankDesignDomain;
params.WarpType                = userInput.WarpType;
switch userInput.WindowType
    case 'Hann'
        params.WindowType = 2;
    case 'Hamming'
        params.WindowType = 3;
    otherwise
        params.WindowType = 1;
end
end

% -------------------------------------------------------------------------
% Conversion Functions
% -------------------------------------------------------------------------
function freq = mel2hz(mel)
freq = cast(700,'like',mel).*((cast(10,'like',mel).^(mel/cast(2595,'like',mel)))-cast(1,'like',mel));
end
function mel = hz2mel(freq)
mel = cast(2595,'like',freq).*log10(cast(1,'like',freq)+freq./cast(700,'like',freq));
end
function bark = hz2bark(freq)
bark = 13.*atan(0.00076.*freq) + 3.5.*atan((freq./7500).^2);
end
function freq = bark2hz(bark)
freq = 650.*sinh(abs(bark)./7);
end
function  erb = hz2erb(hz)
erb = 21.4.*log10(0.00437.*hz+1);
end
function hz = erb2hz(erb)
hz = (10.^(erb./21.4) - 1)/0.00437;
end