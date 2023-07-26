function new_d_load = switchHigh2no(CellType, d_combi, d_load)

%     new_d_load = d_load;

    index_no_old = strcmp(CellType, 'LynG') & strcmp(d_combi, 'A') & strcmp(d_load, 'no');
    index_high_old = strcmp(CellType, 'LynG') & strcmp(d_combi, 'A') & strcmp(d_load, 'high');
    
    [d_load{index_no_old}] = deal('high');
    [d_load{index_high_old}] = deal('no');
    
    new_d_load = d_load;

end