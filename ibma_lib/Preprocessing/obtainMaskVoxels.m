%==========================================================================
%This function performs masking on a list of voxels. It takes in 2 inputs:
%
%masking - the masking job object.
%voxelList - a 2d array of voxel values in the shape of studies by voxels.
%
%Authors: Thomas Maullin
%==========================================================================

function [threshVec, lengthUseful] = obtainMaskVoxels(masking, voxelList)
    
    %Calculate the number of studies and number of voxels.
    studyNumber = size(voxelList, 2);
    voxelNumber = size(voxelList, 1);
    
    %Calculate which entries are useful.
    usefulEntries = ~isnan(voxelList);
    lengthUseful = sum(usefulEntries,2);
    
    %Initialise all voxels to unmasked.
    threshVec = ones(voxelNumber, 1);
    
    %----------------------------------------------------------------------
    %Threshold masking.
    %----------------------------------------------------------------------
    
    if isfield(masking.tm, 'tmp')
        %We have a percentage mask here.
        threshVec(lengthUseful<=studyNumber*(masking.tm.tmp.pthresh/100))= 0;
    elseif isfield(masking.tm, 'tmr')
        %We have a relative mask here.
        threshVec(lengthUseful<=masking.tm.tmr.rthresh)= 0;
    else
        %We have no voxels to threshold out.
    end
    
    %----------------------------------------------------------------------
    %Implicit Masking
    %----------------------------------------------------------------------
    
    if masking.im == 1
        %Apply the default masking.
        threshVec(lengthUseful<=min(10,studyNumber/2)) = 0;
    else
        %Otherwise we need all voxels with any study data.
        threshVec(lengthUseful<2) = 0;
    end
    
    %----------------------------------------------------------------------
    %Explicit masking
    %----------------------------------------------------------------------
    
    if ~isempty(masking.em{1})
        %Find the resized mask.
        [filepath, filename, ext] = fileparts(masking.em{1});
        maskPath = [filepath, filesep, 'r', filename, ext];

        %Read it in.
        maskVol = spm_vol(maskPath);
        mask = spm_read_vols(maskVol);
        mask = reshape(mask, [91*109*91, 1]);

        %Threshold
        threshVec(mask<1) = 0;
    end
    
    %----------------------------------------------------------------------
    
    lengthUseful = lengthUseful(threshVec==1);
    
end