classdef movie < dynamicprops
    properties
        incubation_time
        CellType
        concentration
        replicate
        analysis
    end
    methods
        function obj = movie(val1,val2,val3,val4)
            obj.incubation_time = val1;
            if strcmp(val2,'gSEP')
                obj.CellType = val2;
            elseif strcmp(val2,'LynG')
                obj.CellType = val2;
            elseif strcmp(val2,'Sims')
                obj.CellType = val2;
            elseif strcmp(val2, 'Beads')
                obj.CellType = val2;
            else
                error('Cell type must be "gSEP", "LynG", "Sims" or "Beads"')
            end
            obj.concentration = val3;
            obj.replicate = val4;
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
            idx = true(size(obj));
            for h=1:length(obj)
                for i=1:2:length(varargin)
                    if isprop(obj(h),varargin{i})
                        switch class(varargin{i+1})
                            case 'char'
                                if ~strcmp(obj(h).(varargin{i}),varargin{i+1})
                                    idx(h) = false;
                                end
                            case 'double'
                                if ~(obj(h).(varargin{i})== varargin{i+1})
                                    idx(h) = false;
                                end
                        end
                    else
                        sprintf('%s is no valid property of movie object.',varargin{i})
                        break
                    end
                end
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