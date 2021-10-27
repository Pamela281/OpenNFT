function [isCONT] = getFlagCont(P)
% Function to set feedback type and iGLM flags.
%
% input:
% P - parameter structure
%
% output:
% flags
%__________________________________________________________________________
% Copyright (C) 2016-2021 OpenNFT.org
%
% modified from getFlagsType.m by Jonas Perkuhn

isCONT = false;

if strcmp(P.Prot, 'Cont')
    isCONT = true;
end
