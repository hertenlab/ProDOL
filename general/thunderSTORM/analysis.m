classdef analysis < movie
    properties
        id
        frame
        x
        y
        sigma
        intensity
        offset
        bkgstd
        uncertainty
        fittype
        threshold
        channel
    end
    methods
        function movobj = analysis(val1,val2,val3,val4,val5,val6,val7,val8,val9,val10,val11,val12,val13,val14,val15,val16)
            super_args =  {val13, val14, val15, val16};
            movobj@movie(super_args{:});

            movobj.id = val1;
            movobj.frame = val2;
            movobj.x = val3;
            movobj.y = val4;
            movobj.sigma = val5;
            movobj.intensity = val6;
            movobj.offset = val7;
            movobj.bkgstd = val8;
            movobj.uncertainty = val9;
            movobj.fittype = val10;
            movobj.threshold = val11;
            movobj.channel = val12;
            
        end
    end
end