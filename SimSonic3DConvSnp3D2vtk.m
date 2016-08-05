function dx=SimSonic3DConvSnp3D2vtk(snp3DFileName, vtkFileName, ThinOutFactor);

% SimSonic3DConvSnp3D2vtk converts .snp3D file into .vtk file
%
%   Parameters:
%     ThinOutFactor: should be natural number (1: normal)
%     dx: spatial resolution [m]
%
%   SimSonic3D toolbox
%   Author: Emmanuel Bossy
%   Date: 2012/11/19
%
%   SimSonic3D complementary toolbox
%   Author: Yoshiki NAGATANI / https://ultrasonics.jp/nagatani/fdtd/
%   Date: 2016/08/05


% check parameters
if nargin ~= 3
    error('usage: SimSonic3DConvSnp3D2vtk(snp3DFileName, vtkFileName, ThinOutFactor)');
end
ThinOutFactor = round(ThinOutFactor);


% read .snp3D file
fid=fopen(snp3DFileName,'rb');

Nx=fread(fid,1,'int');
Ny=fread(fid,1,'int');
Nz=fread(fid,1,'int');
t=fread(fid,1,'double');
H=fread(fid,1,'double');
DeltaT=fread(fid,1,'double');
Donnees=fread(fid,'float');
Donnees=reshape(Donnees,Nz,Ny,Nx);
Donnees=permute(Donnees,[3 2 1]);
Max=max(abs(Donnees(:)));

fclose(fid);

dx = H * 1.0e-3;


% Write .vtk file
fileout_vtk=fopen(vtkFileName,'w');
fprintf(fileout_vtk, '%s\n', '# vtk DataFile Version 2.0');
fprintf(fileout_vtk, '%s at %e s (x%d)\n', snp3DFileName, t/1e6, ThinOutFactor);
fprintf(fileout_vtk, '%s\n', 'ASCII');
fprintf(fileout_vtk, '%s\n', 'DATASET STRUCTURED_POINTS');
fprintf(fileout_vtk, '%s %d %d %d\n', 'DIMENSIONS', ceil(Nx/ThinOutFactor), ceil(Ny/ThinOutFactor), ceil(Nz/ThinOutFactor));
fprintf(fileout_vtk, '%s %f %f %f\n', 'ORIGIN', 0.0, 0.0, 0.0);
fprintf(fileout_vtk, '%s %f %f %f\n', 'SPACING', dx*ThinOutFactor, dx*ThinOutFactor, dx*ThinOutFactor);
fprintf(fileout_vtk, '%s %d\n', 'POINT_DATA', ceil(Nx/ThinOutFactor)*ceil(Ny/ThinOutFactor)*ceil(Nz/ThinOutFactor));
fprintf(fileout_vtk, '%s %s(x%d) %s\n', 'SCALARS', 'snp3D', ThinOutFactor, 'float');
fprintf(fileout_vtk, '%s\n', 'LOOKUP_TABLE default');
for z=1:ThinOutFactor:Nz
    for y=1:ThinOutFactor:Ny
        for x=1:ThinOutFactor:Nx
            tmp = 0.0;
            for k=0:ThinOutFactor-1
                for j=0:ThinOutFactor-1
                    for i=0:ThinOutFactor-1
                        tmp = tmp + Donnees(x+i,y+j,z+k);
                    end
                end
            end
            tmp = tmp / (ThinOutFactor*ThinOutFactor*ThinOutFactor);
            fprintf(fileout_vtk, ' %8.3e\n', tmp);
        end
    end
end
fclose(fileout_vtk);
