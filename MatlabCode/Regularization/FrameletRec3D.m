function Rec=FrameletRec3D(C,L)
    R{1} = [1 2 1]/4;
    R{2} = [-1 0 1]/4*sqrt(2);
    R{3} = [-1 2 -1]/4;
    for k=L:-1:2
        C{k-1}{1,1}=FraRec3D(C{k},R,k);
    end
    Rec=FraRec3D(C{1},R,1);
end

function Rec=FraRec3D(C,R,L)
    nR=length(R);
    ImSize=size(C{1,1});
    Rec=(zeros(ImSize));
    for i=1:nR
        temp1=(zeros(ImSize));
        for j=1:nR
            temp2=(zeros(ImSize));
            for k=1:nR
                M3=R{k};
                temp2=temp2+ipermute(ConvSymAsym3D(permute(C{i,j,k},[3 2 1]),M3,L),[3 2 1]);
            end
            M2=R{j};
            temp1=temp1+ConvSymAsym3D(temp2,M2,L);
        end
        M1=R{i};
        Rec=Rec+ipermute(ConvSymAsym3D(permute(temp1,[2 1 3]),M1,L),[2 1 3]);
    end
end