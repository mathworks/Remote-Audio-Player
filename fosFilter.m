% classdef for fosFilter 
% fosFilter is basically a wrapper that holds the states and parameters for
% a forth order sections IIR filter.
%
% Copyright © 2020 The MathWorks, Inc.  
% Francis Tiong (ftiong@mathworks.com)

classdef fosFilter < audioPlugin
    
  properties    
    % public interface
    cFreq = 1000
  end
  
  properties (Constant, Hidden)
    PluginInterface = audioPluginInterface( ...
      'PluginName','fos Filt',...
      audioPluginParameter('cFreq', 'DisplayName',  'Center Freq', 'Label',  'Hz', 'Mapping', { 'log', 20, 20000}) ...
          );
  end 
  
  properties (Access = public)
    % internal state
    Fs = 44100;
    MyFilter 
  end
  
  methods
      
    function out = process(obj, in)
      out = obj.MyFilter(in);
    end
    
    function reset(obj)
      % initialize internal state
      obj.Fs = getSampleRate(obj);
      obj.MyFilter = dsp.FourthOrderSectionFilter;
      calculateCoefficients(obj);
    end

    function set.cFreq(obj, cFreq)
        obj.cFreq = cFreq;
        calculateCoefficients(obj);
    end
    
    % Note that calculation of the coefficients are the same as the one
    % used in the GUI side to display spectrum
    function calculateCoefficients(obj)
        % Function to compute filter coefficients
        N = 4;
        gain = -12;        
        centerFreq = obj.cFreq/(obj.Fs/2);
        bandwidth = 0.1;
        mode = "fos";
        [B,A] = designParamEQ(N,gain,centerFreq,bandwidth,mode,"Orientation","row");
        obj.MyFilter.Numerator = B;
        obj.MyFilter.Denominator = A;
     end
  end
  
end
