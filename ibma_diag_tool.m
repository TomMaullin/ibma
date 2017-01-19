%==========================================================================
%Creates the statistic map, opens the statistic map and adds the tools
%option for voxel diagnosis.
%
%CElist - a column cell array of contrast estimate NII filepaths.
%CSElist - a column cell array of contrast standard error NII filepaths in
%          order corresponding to CElist. 
%outDir - the directory for output.
%statType - the statistic type the user has requested.
%
%Authors: Thomas Maullin, Camille Maumet.
%==========================================================================

function ibma_diag_tool(contrastPaths, contrastSEPaths, outDir, statType)

    %Created the map the user has specified and open it.
    if isfield(statType, 'statType_Q')
        createQ(contrastPaths', contrastSEPaths', outDir);
        spm_image('Display', fullfile(outDir,'QMap.nii'));
    elseif isfield(statType, 'statType_I2')
        createI2(contrastPaths, contrastSEPaths, outDir);
        spm_image('Display', fullfile(outDir,'I2Map.nii'));
    elseif isfield(statType, 'statType_OOE_FFX')
        createOOE_FFX(contrastPaths, contrastSEPaths, outDir);
        spm_image('Display', fullfile(outDir,'OOE_FFXMap.nii'));
    elseif isfield(statType, 'statType_OOE_RFX')
        createOOE_RFX(contrastPaths, contrastSEPaths, outDir);
        spm_image('Display', fullfile(outDir,'OOE_RFXMap.nii'));
    else 
        createBSVar(contrastPaths, contrastSEPaths, outDir);
        spm_image('Display', fullfile(outDir,'BSVarMap.nii'));
    end
    
    %Add the voxel diagnosis to the toolbar.
    ToolsMenu = findall(gcf, 'tag', 'figMenuTools');
    voxelPlot = uimenu('Label','Voxel Plot', 'Parent',ToolsMenu,'Separator','on');
    voxelStat = uimenu('Label','Voxel Statistics', 'Parent',ToolsMenu);
    voxelAdv = uimenu('Label','Voxel Advice', 'Parent',ToolsMenu);
    
    %Add plot options to the voxel diagnosis.
    uimenu('Label','Funnel Plot', 'Parent',voxelPlot, 'Callback',{@funnelPlot, contrastPaths', contrastSEPaths'});
    uimenu('Label','Gailbraith Plot', 'Parent',voxelPlot, 'Callback',{@galbraithPlot, contrastPaths', contrastSEPaths'});
    uimenu('Label','Forest Plot', 'Parent',voxelPlot, 'Callback',{@forestPlot, contrastPaths', contrastSEPaths'});
    
end