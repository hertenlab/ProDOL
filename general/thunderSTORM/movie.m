classdef movie < dynamicprops
    properties 
        %descriptors = struct(); 
        descriptors
        incubation_time
        CellType
        concentration
        replicate
        analysis
        fpath
    end
    methods
        function obj = movie(varargin)
            obj.fpath = '';
            for i=1:nargin()
                if strcmp(varargin(i),'fpath') && nargin>=i+1
                    obj.fpath = varargin(i+1);
                end
            end
            switch nargin()
                case 4 % assume old input format
                    obj.descriptors = struct('inctime',varargin{1},'cellType',varargin{2},'conc',varargin{3},'rep',varargin{4});
                case 1 % assume descriptor struct as input
                    obj.descriptors = varargin{1};
                    obj.fpath = '';
            end
            
            % add old properties to maintain backwards compatibility
            if isfield(obj.descriptors,'inctime')
                obj.incubation_time = obj.descriptors.inctime;
            end
            if isfield(obj.descriptors,'cellType')
                obj.CellType = obj.descriptors.cellType;
            end
            if isfield(obj.descriptors,'conc')
                obj.concentration = obj.descriptors.conc;
            end
            if isfield(obj.descriptors,'rep')
                obj.replicate = obj.descriptors.rep;
            end
           
            obj.analysis;           
        end
        
        function analysisSelected = returnanalysis(obj, varargin)
            validchannels = {'blue','green','greenbleached','red'};
            validfittype = {'single', 'multi'};
            p = inputParser;            
            addParameter(p,'channel','',@(x) any(validatestring(x,validchannels)));
            addParameter(p,'threshold','', @(x) isnumeric(x));
            addParameter(p,'fittype', '', @(x) any(validatestring(x,validfittype)));
            
            mask = ones(length(obj.analysis),1);
            
            for i=1:2:nargin-1
                    mask_temp = arrayfun(@(x)strcmp(x.(varargin{i}),varargin{i+1}),[obj.analysis])';
                    mask = and(mask, mask_temp);
                    analysisSelected = obj.analysis(mask);
            end
        end
        
        function matches = moviesWithProperty(obj,varargin)
            idx = false(size(obj));
            if numel(varargin)==1
                tmp = cellfun(@(x) isequal(x,varargin{1}),{obj(:).descriptors}');
                if sum(tmp)==1
                    idx = find(tmp,true);
                end                
            elseif numel(varargin)>1 & rem(size(varargin,2),2)==0
                for h=1:length(obj)
                    chck = 0;
                    for i=1:2:length(varargin)
                        if isprop(obj(h),varargin{i})
                            switch class(varargin{i+1})
                                case 'char'
                                    if strcmp(obj(h).(varargin{i}),varargin{i+1})
                                        chck = chck+1;
                                    end
                                case 'double'
                                    if obj(h).(varargin{i})== varargin{i+1}
                                        chck = chck+1;
                                    end
                            end
                            
                        else
                            sprintf('%s is no valid property of movie object.',varargin{i})
                            break
                        end
                    end
                    if chck==size(varargin,2)/2
                        idx(h) = true;
                    end
                end
            else
                error('invalid input')
            end
            matches = obj(idx);
        end
        
        function ds_filtered = filteranalysisbymask(obj, maskfile, pixelsize)
            % input maskfile: path to mask file
            % input pixelsize: pixel size provided to thunderSTORM in nm
            
            % load mask image file
            ds = obj;
            if ~exist(maskfile, 'file')
                fprintf('warning: maskfile not found:\n%s\npoints are not filtered\n', maskfile);
                % if no mask file is found points are not filtered. Note:
                % this implementation assumes an image size of 512 x 512 px
                mask = uint16(255*ones(512,512));
            else
                mask = imread(maskfile);
            end
            
            % loop through analysis objects for dataset
            for i=1:length(ds(1).analysis)
                points_raw = [ds.analysis(i).x, ds.analysis(i).y]./pixelsize;
                raw = length(points_raw);

                % confirm that points were found before filtering
                if ~isempty(points_raw)
                    % create mask filter vector
                    points_idx_filtered = logical(diag(mask(floor(points_raw(:,2))+1,floor(points_raw(:,1))+1))); 
                    
                    filtered = sum(points_idx_filtered);
                    
                    % remove points outside mask
                    ds.analysis(i).id = ds.analysis(i).id(points_idx_filtered);
                    ds.analysis(i).frame = ds.analysis(i).frame(points_idx_filtered);
                    ds.analysis(i).x = ds.analysis(i).x(points_idx_filtered)./pixelsize; % convert nm from thunderSTORM into pixels
                    ds.analysis(i).y = ds.analysis(i).y(points_idx_filtered)./pixelsize; % convert nm from thunderSTORM into pixels
                    ds.analysis(i).sigma = ds.analysis(i).sigma(points_idx_filtered)./pixelsize; % convert nm from thunderSTORM into pixels
                    ds.analysis(i).intensity = ds.analysis(i).intensity(points_idx_filtered);
                    ds.analysis(i).offset = ds.analysis(i).offset(points_idx_filtered);
                    ds.analysis(i).bkgstd = ds.analysis(i).bkgstd(points_idx_filtered)./pixelsize;  % convert nm from thunderSTORM into pixels
                    ds.analysis(i).uncertainty = ds.analysis(i).uncertainty(points_idx_filtered)./pixelsize;  % convert nm from thunderSTORM into pixels
                else
                    fprintf('Analysis object does not contain points. Skipping!\n')
                end            
            end
            % return updated movie object
            ds_filtered = ds;
        end
        
    end
end