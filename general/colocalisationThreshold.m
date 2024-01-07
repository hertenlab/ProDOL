% function for calculating of the colocalisation distance threshold from a
% set of specific and random (from rotated positions) colocalisation varied
% over a set of thresholds
% 
% input
% - Coloc, ColocRandom
%   Number of colocalizing particles. Enter only values to be considered
%   (typically only those with succesful registration)
% - thresholds
%   distance thresholds for colocalisation in Coloc. length must match
%   second dimension of Coloc
% - varargin
%   use additional input 'plot' to create figure showing specific
%   colocalisation (Coloc - ColocRandom) versus spatial thresholds

function finalThreshold = colocalisationThreshold(Coloc, ColocRandom, thresholds,saveDir, targetName, showIntermediate,gT, varargin)

    if ~isequal(size(Coloc), size(ColocRandom)) || ...
            ~isequal(size(Coloc,2),length(thresholds))
            error('input dimensions mismatch')
    end
    
 % Find Tolerance Threshold as mean value
    meanCol = nanmean(Coloc,1);
    meanColRandom = nanmean(ColocRandom,1);

    colocScore=meanCol/max(meanCol)-meanColRandom/max(meanColRandom);
    colScoreNorm=colocScore/max(colocScore);
    differences=abs(diff(colScoreNorm));
    meanColScoreNorm=mean(differences);

    SNR=max(colocScore)/meanColScoreNorm;

    if SNR<5 
            ColMean = (meanCol(1:end-6)+meanCol(2:end-5)+meanCol(3:end-4)+meanCol(4:end-3)+meanCol(5:end-2)+meanCol(6:end-1)+meanCol(7:end))/7;
            ColMeans2 = [meanCol(1:3),ColMean,meanCol(end-2:end)];
            
            ColMeanRandom = (meanColRandom(1:end-6)+meanColRandom(2:end-5)+meanColRandom(3:end-4)+meanColRandom(4:end-3)+meanColRandom(5:end-2)+meanColRandom(6:end-1)+meanColRandom(7:end))/7;
            ColMeans2Random = [meanColRandom(1:3),ColMeanRandom,meanColRandom(end-2:end)];

            [~,index] = max(ColMeans2/max(ColMeans2Random)-meanColRandom/max(ColMeans2Random));
            finalThreshold = thresholds(index);
            if exist("gT", "var")
                T=round(mean(gT));
                [~,index] = max(ColMeans2(1:T+5)/max(ColMeans2)-ColMeans2Random(1:T+5)/max(ColMeans2Random));
                finalThreshold = thresholds(index);
            end
    elseif  SNR>=5
        [~,index] = max(meanCol/max(meanCol)-meanColRandom/max(meanColRandom));
        finalThreshold = thresholds(index);
        if SNR>8
           [~,refT] = max(colocScore);
           gT=[gT,refT];
           assignin('caller', 'gT', gT);
        end
    end
    
    % plot specific colocalisation
    if ~isempty(varargin) && strcmp(varargin{1}, 'plot')
        f_coloc=figure();
        title(['Colocalisation Threshold ' inputname(1)])
        hold on
        Col = plot(thresholds,meanCol/max(meanCol)-meanColRandom/max(meanColRandom),'linewidth',3,'Color', [0 0.5 0]);
        ax = gca;
        ax.XAxis.Label.String = 'spatial tolerance [px]';
        ax.YAxis.Label.String = {'normalized number of' 'specific colocalisations Z'};

        scatter(Col.XData(index), Col.YData(index),100,[0 0.5 0]);
        line([Col.XData(index) Col.XData(index)], [0 Col.YData(index)],...
            'LineStyle', '--', 'Color', [0 0.5 0]);
        text(Col.XData(index), 0.05*ax.YLim(2),num2str(Col.XData(index)),...
            'Color',[0 0.5 0],'BackgroundColor', 'white','HorizontalAlignment', 'center',...
            'FontSize',10);
        if contains(targetName,"Halo")
            if isdeployed()
                saveas(f_coloc,strcat(saveDir,'ColocThreshold_Halo.png'));
            else
                savefig(strcat(saveDir,'ColocThreshold_Halo.fig'));
            end
        elseif contains(targetName,"SNAP")
            if isdeployed()
                saveas(f_coloc,strcat(saveDir,'ColocThreshold_SNAP.png'));
            else
                savefig(strcat(saveDir,'ColocThreshold_SNAP.fig'));
            end
        else
        	if isdeployed()
                saveas(f_coloc,strcat(saveDir,'ColocThreshold_other.png'));
            else
                savefig(strcat(saveDir,'ColocThreshold_other.fig'));
            end   
        end
        if showIntermediate==0
            close(f_coloc);
        end
    end
end