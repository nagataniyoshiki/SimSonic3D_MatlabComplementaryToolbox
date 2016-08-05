function SimSonic3DConvMap3D2vtk(Map3DFileName, vtkFileName, ThinOutFactor, dx);

%
% SimSonic3DConvMap3D2vtk converts .map3D file into .vtk file
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
if nargin ~= 4
    error('usage: SimSonic3DConvMap3D2vtk(Map3DFileName, vtkFileName, ThinOutFactor, dx)');
end
ThinOutFactor = round(ThinOutFactor);


% Read .map3D file
fid=fopen(Map3DFileName,'rb');
X = fread(fid,1,'int');
Y = fread (fid,1,'int');
Z = fread (fid,1,'int');
Map = uint8(fread(fid,'uchar'));

fclose(fid);

Map=reshape(Map,Z,Y,X);
Map=permute(Map,[3 2 1]);


% Write .vtk file
fileout_vtk=fopen(vtkFileName,'w');
fprintf(fileout_vtk, '%s\n', '# vtk DataFile Version 2.0');
fprintf(fileout_vtk, '%s(x%d)\n', Map3DFileName, ThinOutFactor);
fprintf(fileout_vtk, '%s\n', 'ASCII');
fprintf(fileout_vtk, '%s\n', 'DATASET STRUCTURED_POINTS');
fprintf(fileout_vtk, '%s %d %d %d\n', 'DIMENSIONS', ceil(X/ThinOutFactor), ceil(Y/ThinOutFactor), ceil(Z/ThinOutFactor));
fprintf(fileout_vtk, '%s %f %f %f\n', 'ORIGIN', 0.0, 0.0, 0.0);
fprintf(fileout_vtk, '%s %f %f %f\n', 'SPACING', dx*ThinOutFactor, dx*ThinOutFactor, dx*ThinOutFactor);
fprintf(fileout_vtk, '%s %d\n', 'POINT_DATA', ceil(X/ThinOutFactor)*ceil(Y/ThinOutFactor)*ceil(Z/ThinOutFactor));
fprintf(fileout_vtk, '%s %s(x%d) %s\n', 'SCALARS', Map3DFileName, ThinOutFactor, 'int');
fprintf(fileout_vtk, '%s\n', 'LOOKUP_TABLE default');
for z=1:ThinOutFactor:Z
    for y=1:ThinOutFactor:Y
        for x=1:ThinOutFactor:X
            fprintf(fileout_vtk, ' %d\n', Map(x,y,z));
        end
    end
end
fclose(fileout_vtk);
