function Dec = FrameletDec3D(A,L)
    D{1} = [1 2 1]/4;
    D{2} = [1 0 -1]/4*sqrt(2);
    D{3} = [-1 2 -1]/4;
    Dec=cell(1,L);
    for k=1:L
        Dec{k}=FraDec3D(A,D,k);
        A=Dec{k}{1,1};
    end
end

function Dec=FraDec3D(A,D,L)
    nD=length(D);
    Dec=cell(nD,nD,nD);
    for i=1:nD
        M1=D{i};
            tempi=ipermute(ConvSymAsym3D(permute(A,[2 1 3]),M1,L),[2 1 3]);
        for j=1:nD
            M2=D{j};        
            tempj=ConvSymAsym3D(tempi,M2,L);
            for k=1:nD
                M3=D{k};        
                tempk=ipermute(ConvSymAsym3D(permute(tempj,[3 2 1]),M3,L),[3 2 1]);
                Dec{i,j,k}=single(tempk);
            end
        end
    end
end