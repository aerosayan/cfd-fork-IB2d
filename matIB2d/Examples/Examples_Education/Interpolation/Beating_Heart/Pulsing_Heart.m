%-------------------------------------------------------------------------------------------------------------------%
%
% IB2d is an Immersed Boundary Code (IB) for solving fully coupled non-linear 
% 	fluid-structure interaction models. This version of the code is based off of
%	Peskin's Immersed Boundary Method Paper in Acta Numerica, 2002.
%
% Author: Nicholas A. Battista
% Email:  nick.battista@unc.edu
% Date Created: May 27th, 2015
% Institution: UNC-CH
%
% This code is capable of creating Lagrangian Structures using:
% 	1. Springs
% 	2. Beams (*torsional springs)
% 	3. Target Points
%	4. Muscle-Model (combined Force-Length-Velocity model, "HIll+(Length-Tension)")
%
% One is able to update those Lagrangian Structure parameters, e.g., spring constants, resting %%	lengths, etc
% 
% There are a number of built in Examples, mostly used for teaching purposes. 
% 
% If you would like us %to add a specific muscle model, please let Nick (nick.battista@unc.edu) know.
%
%--------------------------------------------------------------------------------------------------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: creates the RUBBERBAND-EXAMPLE geometry and prints associated input files
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Pulsing_Heart()

%
% Grid Parameters (MAKE SURE MATCHES IN input2d !!!)
%
Nx =  64;        % # of Eulerian Grid Pts. in x-Direction (MUST BE EVEN!!!)
Ny =  64;        % # of Eulerian Grid Pts. in y-Direction (MUST BE EVEN!!!)
Lx = 1.0;        % Length of Eulerian Grid in x-Direction
Ly = 1.0;        % Length of Eulerian Grid in y-Direction


% Immersed Structure Geometric / Dynamic Parameters %
N = 2.5*Nx;              % Number of Lagrangian Pts. (2x resolution of Eulerian grid)
struct_name = 'heart'; % Name for .vertex, .spring, etc files.


% Call function to construct geometry
frac1 = 0.0135; %0.022
[xA,yA] = give_Me_Immsersed_Boundary_Geometry_1(Lx,Nx,frac1);
Nb1 = length(xA);


% Call function to construct geometry
frac2 = 0.0085; %0.015
[xB,yB] = give_Me_Immsersed_Boundary_Geometry_2(Lx,Nx,frac2,Nb1);


% Plot Geometry to test BEFORE taking out pts.
figure(1)
plot(xA,yA,'r-'); hold on;
plot(xA,yA,'*'); hold on;
plot(xB,yB,'m-'); hold on;
plot(xB,yB,'g*'); hold on;
xlabel('x'); ylabel('y');
axis([0 Lx 0 Ly]);


% Cuts hole into heart geometry
n1 = 145; n2 = 180;
[xA,yA,xB,yB] = please_Take_Out_Points(xA,yA,xB,yB,n1,n2);


% Plot Geometry to test AFTER taking out pts.
figure(2)
plot(xA,yA,'r-'); hold on;
plot(xA,yA,'*'); hold on;
plot(xB,yB,'m-'); hold on;
plot(xB,yB,'g*'); hold on;
xlabel('x'); ylabel('y');
axis([0 Lx 0 Ly]);

% Print STATES A,B, and C:
print_States(xA,yA,'State_A');
print_States(xB,yB,'State_B');

% Print files to .txt files
%please_Print_Vertices_To_File(xA,yA,xB,yB)

% Prints .vertex file!
print_Lagrangian_Vertices(xA,yA,struct_name);

% Prints .spring file!
k_Spring = 1e3; ds_Rest = 0;
print_Lagrangian_Springs(xA,k_Spring,ds_Rest,struct_name,n1)

% Prints .target file!
k_Target = 2e10;
print_Lagrangian_Target_Pts(xA,k_Target,struct_name);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: prints VERTEX points to a file called State_<j>.pts
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function print_States(xA,yA,struct_name)

    N = length(xA);

    vertex_fid = fopen([struct_name '.pts'], 'w');

    %Loops over all Lagrangian Pts.
    for s = 1:N
        X_v = xA(s);
        Y_v = yA(s);
        fprintf(vertex_fid, '%1.16e %1.16e\n', X_v, Y_v);
    end

    fclose(vertex_fid);  
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: prints VERTEX points to a file called heart.vertex
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function print_Lagrangian_Vertices(xLag,yLag,struct_name)

    N = length(xLag);

    vertex_fid = fopen([struct_name '.vertex'], 'w');

    fprintf(vertex_fid, '%d\n', N );

    %Loops over all Lagrangian Pts.
    for s = 1:N
        X_v = xLag(s);
        Y_v = yLag(s);
        fprintf(vertex_fid, '%1.16e %1.16e\n', X_v, Y_v);
    end

    fclose(vertex_fid); 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: prints Vertex points to a file called heart.target
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function print_Lagrangian_Target_Pts(xLag,k_Target,struct_name)

    N = length(xLag);

    target_fid = fopen([struct_name '.target'], 'w');

    fprintf(target_fid, '%d\n', N );

    %Loops over all Lagrangian Pts.
    for s = 1:N
        fprintf(target_fid, '%d %1.16e\n', s, k_Target);
    end

    fclose(target_fid); 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: prints SPRING points to a file called rubberband.spring
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function print_Lagrangian_Springs(xLag,k_Spring,ds_Rest,struct_name,n1)

    N = length(xLag);

    spring_fid = fopen([struct_name '.spring'], 'w');

    fprintf(spring_fid, '%d\n', N );

    %spring_force = kappa_spring*ds/(ds^2);

    %SPRINGS BETWEEN VERTICES
    for s = 1:N
            if s < n1        
                fprintf(spring_fid, '%d %d %1.16e %1.16e\n', s, s+1, k_Spring, ds_Rest);  
            elseif ( (s>=n1+1) && (s<N) )
                fprintf(spring_fid, '%d %d %1.16e %1.16e\n', s, s+1, k_Spring, ds_Rest);  
            elseif s == N
                fprintf(spring_fid, '%d %d %1.16e %1.16e\n', s, 1,   k_Spring, ds_Rest);  
            end
    end
    fclose(spring_fid); 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: creates the Lagrangian structure geometry for PHASE 1
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xLag,yLag] = give_Me_Immsersed_Boundary_Geometry_1(Lx,Nx,frac)

% The immsersed structure is a heart %
tVec = 0:Lx/(2*Nx):2*pi;
for i=1:length(tVec)
    t = tVec(i);
    xLag(i)	=	16*sin(t)^3;
    yLag(i)	=	13*cos(t)-5*cos(2*t)-2*cos(3*t)-cos(4*t);
end

xLag = frac*xLag + 0.5;
yLag = frac*yLag + 0.5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: creates the Lagrangian structure geometry for PHASE 1
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xLag,yLag] = give_Me_Immsersed_Boundary_Geometry_2(Lx,Nx,frac,Nb)

% The immsersed structure is a heart %
ds = 2*pi/(Nb-1);
tVec = 0:ds:2*pi;

for i=1:length(tVec)
    t = tVec(i);
    xLag(i)	=	16*sin(t)^3;
    yLag(i)	=	13*cos(t)-5*cos(2*t)-2*cos(3*t)-cos(4*t);
end

xLag = frac*xLag + 0.5;
yLag = frac*yLag + 0.5;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: creates the Lagrangian structure geometry for PHASE 2 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xLag,yLag] = give_Me_Immsersed_Boundary_Geometry_3(Lx,Nx,frac,Nb)

% The immsersed structure is a heart %
ds = 2*pi/(Nb-1);
tVec = 0:ds:2*pi;
for i=1:length(tVec)
    t = tVec(i);
    r(i) = 1 - sin(t);
    xLag(i)	=	r(i)*cos(t);
    yLag(i)	=	r(i)*sin(t);
end

xLag = frac*xLag;
yLag = frac*yLag;

minY = min(yLag);
yLag = yLag - 3*minY/8;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: take out Lagrangian Pts.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x1,y1,x2,y2] = please_Take_Out_Points(x1,y1,x2,y2,n1,n2)


x1 = [x1(1:n1) x1(n2:end)];
y1 = [y1(1:n1) y1(n2:end)];

x2 = [x2(1:n1) x2(n2:end)];
y2 = [y2(1:n1) y2(n2:end)];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: prints all Vertices to File
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function please_Print_Vertices_To_File(X1,Y1,X2,Y2)

fileID = fopen('All_Positions.txt','w');
for j=1:length(X1)
    fprintf(fileID,'%1.16e %1.16e %1.16e %1.16e\n', X1(j),Y1(j),X2(j),Y2(j) );
end
fclose(fileID);




