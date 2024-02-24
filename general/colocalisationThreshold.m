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
            meanCol = movmean(meanCol, 7);
            meanColRandom = movmean(meanColRandom, 7);
    elseif SNR>8
           [~,refT] = max(colocScore);
           gT=[gT,refT];
           assignin('caller', 'gT', gT);
    end
    
    cutOff=meanCol/max(meanCol)-meanColRandom/max(meanColRandom);
    
    if SNR<5 && mean(gT)>0 && mean(gT)+10<length(cutOff)
        T=round(mean(gT));
        cutOff=cutOff(1:T+10);
    end
    
    [~,index] = max(cutOff);
    finalThreshold = thresholds(index);    
    
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
