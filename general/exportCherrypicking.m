function cherryData = exportCherrypicking(imageSet)
    tmp = [imageSet.childImages];
    cherryData{1} = [tmp.include];
    cherryData{2} = [tmp.description];
end