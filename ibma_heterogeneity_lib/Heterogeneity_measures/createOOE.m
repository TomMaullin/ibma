%==========================================================================
%Generate a NIFTI file for fixed effects overall observed effect from a set
%of studies. This function takes in an input of:
%
%CElist - a column cell array of contrast estimate NII filepaths.
%CSElist - a column cell array of contrast standard error NII filepaths in
%          order corresponding to CElist. 
%outdir - an output directory for the resultant NII.
%
%Authors: Thomas Maullin, Camille Maumet.
%==========================================================================

function createOOE(CElist, CSElist, outdir)

    %Find out how many studies are being used:
    length = max(size(CSElist));
    
    %Create a string for the expression of the equation calculated overall
    %observed effect. This will be passed to imcalc.
    stringNum = '(';
    stringDen = '(';
    
    %For each study, add the correct expression to the numerator and
    %denominator of the fraction.
    for(k = 1:(length-1))
        stringNum = [stringNum, 'i', num2str(k), './(i' num2str(length+k), '.^2) + '];
        stringDen = [stringDen, '1./(i', num2str(length+k), '.^2) + '];
    end
    
    %Add the last study.
    stringNum = [stringNum, 'i', num2str(length), './(i' num2str(2*length), '.^2))'];
    stringDen = [stringDen, '1./(i', num2str(2*length), '.^2))'];
    string = [stringNum './' stringDen];
    
    %Create the batch variable.
    matlabbatch{1}.spm.util.imcalc.input = [CElist, CSElist]';
    matlabbatch{1}.spm.util.imcalc.output = 'OOEMap';
    matlabbatch{1}.spm.util.imcalc.outdir = {outdir};
    matlabbatch{1}.spm.util.imcalc.expression = string;
    matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{1}.spm.util.imcalc.options.mask = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 1;
    matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
    
    %Run the batch.
    spm_jobman('run', matlabbatch)

end