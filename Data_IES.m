si = [];
si.eta_H2=0.75;
si.eta=39.65;%kwh/kg
si.aerfa=0.1;%掺氢比10%
si.daita=2;%甲烷和氢气转换系数
si.rou_H2=39.062;%氢气密度（70MPa，39.062kg/m3）
si.rou_CH4=312.496;%甲烷密度
si.rou_mix=285.1526;%混合密度（10%）
si.M_mix=14.436;%以掺氢比（10%）的混合摩尔质量
si.lamuda_CH4=0.8;%甲烷燃烧反应生成物计量数
si.lamuda_H2=0.9;%氢气燃烧反应生成物计量数 
si.fai_CH4=0.888;%甲烷摩尔分数转换系数
si.fai_H2=0.112;%氢气摩尔分数转换系数
si.T_in=640;%HT进气口燃烧温度K
si.T_comCH4=2223;%甲烷稳态燃烧温度K
si.T_comH2=2293;%氢气稳态燃烧温度K
si.HeatCH4=39.8;%甲烷热值
si.HeatH2=12.75;%氢气热值
si.Linepack0=100;%管存初值
si.aerfa_nv_CH4=1;%甲烷体积换算系数
si.aerfa_nv_H2=1;%氢气体积换算系数
si.N_in_CH4=0.9;%甲烷初始摩尔分数
si.N_in_H2=0.1;%氢气初始摩尔分数
si.Wc=100;%弃风惩罚成本系数
si.Horizon=24;

si.M_air=28.9634;si.M_H2=2.01588;si.M_CH4=16.043;%摩尔质量
si.tao=0.03;%GC 耗气率
si.fp=3.5;%天然气燃料成本系数3.5     CCS:1.7  MR:0.3
si.HTcost=1.5;%CHP的燃料成本系数  1.5
si.NumEn=30;si.NumEl=41;
si.NumGn=20;si.NumGl=19;si.NumGC=3;si.NumGW=4;
si.NumHT=2;%HGMT数
si.NumPG=3;
si.inonoff=[1 1 0]';%initial state of thermal units
si.minup=[4 4 4];
si.mindown=si.minup;
si.stcost=[280 280 280];si.sdcost=[3200 3200 3200];
si.idle=1;
si.on=0;
si.standby=0;
si.mindown_EL=4;
si.c=[0 0 0];si.stcost=[2800 2800 2800];si.sdcost=[3200 3200 3200];
si.HTlocat_E=[22;25];si.HTlocat_G=[2;7];%HT在电网和气网的安装位置
si.PGlocat=[1;2;13];%nonNGU在电网的安装位置
si.data=xlsread('Power.xlsx','Line data','A2:D42');
PPD=xlsread('Power','Units data','A2:F4');%nonNGU的数据
LNO=xlsread('Power','Bus load','A2:B21');
GLD=xlsread('Gas.xlsx','Gas load','A2:D21');
GWD=xlsread('Gas.xlsx','Gas well','A2:E5');
si.TPD=xlsread('Gas.xlsx','Pipeline','A2:E17');
GCD=xlsread('Gas.xlsx','Compressor','A2:F4');

%氢混燃机 = 数量   电网位置  气网位置  最低耗气量  最高耗气量

HT=[
1	22	2	500	1500
% 2	23	7	500	1500
3   25  10  500	1500
];
si.NumHT=size(HT,1);
si.HTlocat_E=HT(:,2);si.HTlocat_G=HT(:,3);
si.VHTmin=zeros(si.NumGn,1);si.VHTmin(si.HTlocat_G)=HT(:,4);
si.VHTmax=zeros(si.NumGn,1);si.VHTmax(si.HTlocat_G)=HT(:,5);
si.PHTmin=zeros(si.NumEn,1);si.PHTmin(si.HTlocat_E)=0;
si.PHTmax=zeros(si.NumEn,1);si.PHTmax(si.HTlocat_E)=600;%HT的数量，在电网和气网中的位置,最大耗气量,最大最小功率（取值足够大）
si.GHTmin=0;si.GHTmax=5000;

%Number 	Bus at the power system 	Node at the gas system 	Conversion coefficient (kcf/MW)	P2G min	P2G max
P2G=[
1	10	4	1.5000	0	80
2	23	10	1.2000	0	80
];
si.NumP2G=2;
si.P2Glocat_E=P2G(:,2);si.P2Glocat_G=P2G(:,3);
si.P2Gmin=zeros(si.NumEn,1);si.P2Gmin(si.P2Glocat_E)=P2G(:,5);
si.P2Gmax=zeros(si.NumEn,1);si.P2Gmax(si.P2Glocat_E)=P2G(:,6);
si.P2G_Gmax=zeros(si.NumGn,1);si.P2G_Gmax(si.P2Glocat_G)=P2G(:,6);%P2G的数量，在电网和气网中的位置,最大功率

si.P2G_min=zeros(si.NumP2G,1);si.P2G_min=P2G(:,5);
si.P2G_max=zeros(si.NumP2G,1);si.P2G_max=P2G(:,6);

T_EL=[
1	10	4	300   360   0   10   0    1e5
2	23	10	300   360   0   10   0    1e5
];
si.T_ELmin=zeros(si.NumEn,1);si.T_ELmin(si.P2Glocat_E)=T_EL(:,4);
si.T_ELmax=zeros(si.NumEn,1);si.T_ELmax(si.P2Glocat_E)=T_EL(:,5);
si.U_ELmin=zeros(si.NumEn,1);si.U_ELmin(si.P2Glocat_E)=T_EL(:,6);
si.U_ELmax=zeros(si.NumEn,1);si.U_ELmax(si.P2Glocat_E)=T_EL(:,7);
si.I_ELmin=zeros(si.NumEn,1);si.I_ELmin(si.P2Glocat_E)=T_EL(:,8);
si.I_ELmax=zeros(si.NumEn,1);si.I_ELmax(si.P2Glocat_E)=T_EL(:,9);

si.eta_H2min=0.8;si.eta_H2max=1;%产氢效率最大最小值

%No.  电网位置  Pmin  Pmax Gmin Gmax
% CHP=[
% %     1	10 4	0	400   0    1000
%     2	23 10	0	500   0    1500
%     ];
% si.NumCHP=size(CHP,1);
% si.CHPlocat_E=CHP(:,2);si.CHPlocat_G=CHP(:,3);
% si.P_CHPmin=zeros(si.NumEn,1);si.P_CHPmin(si.CHPlocat_E)=CHP(:,4);
% si.P_CHPmax=zeros(si.NumEn,1);si.P_CHPmax(si.CHPlocat_E)=CHP(:,5);
% si.G_CHPmin=zeros(si.NumGn,1);si.G_CHPmin(si.CHPlocat_G)=CHP(:,6);
% si.G_CHPmax=zeros(si.NumGn,1);si.G_CHPmax(si.CHPlocat_G)=CHP(:,7);

% 储氢罐=数量     位置      最小容量     最大容量（m3）
H_storage=[
    1    22  400  2000 0 1000; 
%     2    23  200  1000 0 500; 
    3    25  400  2000 0 1000;
    ];
 si.NumHys=size(H_storage,1);
 si.Hyslocat=H_storage(:,2);
 si.Hysmin=zeros(si.NumEn,1); si.Hysmin(si.Hyslocat)=H_storage(:,3);
 si.Hysmax=zeros(si.NumEn,1); si.Hysmax(si.Hyslocat)=H_storage(:,4);
 si.GHysmin=zeros(si.NumEn,1); si.GHysmin(si.Hyslocat)=H_storage(:,5);
 si.GHysmax=zeros(si.NumEn,1); si.GHysmax(si.Hyslocat)=H_storage(:,6);%Hys的数量，位置，最大，最小储气量   %%（最大最小流量）

%% 

si.PGmin=zeros(si.NumPG,1);si.PGmin=PPD(1:3,6);%nonNGU最大最小出力
si.PGmax=zeros(si.NumPG,1);si.PGmax=PPD(1:3,5);
si.NGc=PPD(1:3,2);si.NGb=2.5*PPD(1:3,3);si.NGa=PPD(1:3,4);%nonNGU发电成本系数
si.ud=si.PGmax*0.5;%nonNGU爬坡速率

si.GWlocat=GWD(:,2);%气源安装位置
si.Gflowmax=si.TPD(:,5);%气支路潮流限制
si.pimin=GLD(:,4);si.pimax=GLD(:,3);%气节点压力最大最小
si.GCmax=GCD(:,6);si.C_in=GCD(:,2);si.C_out=GCD(:,3);si.C_ratiomin=GCD(:,4);si.C_ratiomax=GCD(:,5);%压缩机相关参数
si.GWmin=zeros(si.NumGn,1);si.GWmin(GWD(:,2))=0;%气源最大最小出力
si.GWmax=zeros(si.NumGn,1);si.GWmax(GWD(:,2))=GWD(:,3);
%% 
% 风机最小出力  风机额定容量（没用到）  风机所在电网的节点位置
PWDATA=[
    0    300 10; 
    0    300 23; 
    ];%数量太多
si.PWlocat=PWDATA(:,3);%风机所在节点位置
PW=zeros(si.NumEn,1);
PWrate=[0.67 0.68 0.80 0.82 0.82 0.92 0.98 1.00 0.88 0.86 0.84 0.84 0.82 0.79 0.82 0.85 0.87 0.89 0.85 0.80 0.89 0.85 0.87 0.88];
% PWrate=[0.25 0.22 0.20 0.18 0.22 0.30 0.40 0.50 0.62 0.70 0.78 0.85 0.90 0.95 1.00 0.98 0.95 0.88 0.80 0.70 0.60 0.50 0.40 0.30];
for t=1:si.Horizon
    PW(si.PWlocat,t)=200*PWrate(t);%实际风电功率曲线
end
si.PW=PW;


%% P=B*theta 直流潮流方程
si.Y=zeros(si.NumEn);
for i=1:si.NumEl
    p=si.data(i,1);q=si.data(i,2);si.Y(p,q)=si.Y(p,q)-1./si.data(i,3);si.Y(q,p)=si.Y(p,q);si.Y(q,q)=si.Y(q,q)+1./si.data(i,3);si.Y(p,p)=si.Y(p,p)+1./si.data(i,3);
end
si.M=zeros(si.NumEl,si.NumEn);
for i=1:si.NumEl
    p=si.data(i,1);q=si.data(i,2);si.M(i,p)=1;si.M(i,q)=-1;
end

%% 电气负荷曲线
% PL=[0.68 0.64 0.62 0.60 0.61 0.63 0.68 0.70 0.73 0.81 0.89 0.92 0.95 0.95 0.97 0.95 0.93 0.91 0.89 0.90 0.93 0.91 0.86 0.86]*1600;%电负荷典型曲线 1900
PL=[0.68 0.64 0.62 0.60 0.61 0.63 0.68 0.70 0.73 0.81 0.89 0.92 0.92 0.89 0.81 0.73 0.70 0.68 0.63 0.61 0.60 0.62 0.64 0.68]*1600;%电负荷典型曲线 1900
si.PL=zeros(si.NumEn,si.Horizon);
for t=1:si.Horizon
    for i=1:size(LNO,1)
        si.PL(LNO(i,1),t)=PL(t)*LNO(i,2);%实际电负荷曲线\
    end
end
GLrate=[1.0 1.0 0.9 0.9 0.85 1.0 1.0 0.6 0.6 0.6 0.8 0.7 1.0 1.0 0.7 0.7 1.0 1.0 1.0 0.7 0.7 0.7 0.8 1.0];
% GLrate=[1.0 1.0 0.9 0.9 1.0 1.0 1.0 0.7 0.7 0.7 0.8 0.7 1.0 1.0 0.9 0.9 1.0 1.0 1.0 0.7 0.7 0.7 0.8 1.0];%气负荷典型曲线
% GLrate=[1.0 1.0 0.9 0.9 1.0 1.0 1.0 0.7	0.7	0.7	0.8	0.7	0.7 0.8 0.7 0.7 0.7 1.0 1.0 1.0 0.9 0.9 1.0 1.0];

GL=zeros(si.NumGn,1);
GL(GLD(:,1))=GLD(:,2)*0.5;
for t=1:si.Horizon
    si.GL(:,t)=GL'*GLrate(t);%实际气负荷曲线
end

%% 节点热值

si.Ratiomin=0.05;si.Ratiomax=0.20;%掺氢比上下限
si.H_nodemin=(1-si.Ratiomax)*si.HeatCH4+si.Ratiomax*si.HeatH2;si.H_nodemax=(1-si.Ratiomin)*si.HeatCH4+si.Ratiomin*si.HeatH2;%节点热值上下限
%% 热网数据
si.temp_H=[-3 -3 -3 -3 -3 -1 1 3 3 5 6 7 8 9 7 5 5 4 4 -1 -2 -2 -2 -3]+28;
si.c=0.0011742; %kWh/（kg℃） %4200 J/（kg℃）1kW·h=3.6e6 J。
si.Node=14;si.Pipe=13;
si.pipe=[
    %  f	t	length(m)	flowrate(kg/h) lambda Heat transfer coefficient of pipeline (kW/moC)
    0	1	800	        2.5*3600      0.2*1e-3
    1	2	800	        2.4*3600      0.2*1e-3
    2	3	800	        2.3*3600	  0.2*1e-3
    3	4	800	        2.0*3600      0.2*1e-3
    4	5	800	       	1.9*3600      0.2*1e-3
    5	6	800      	1.5*3600      0.2*1e-3
    2	7	800      	1.7*3600      0.2*1e-3
    4	8	800      	1.6*3600      0.2*1e-3
    5	9	800      	1.5*3600      0.2*1e-3
    2	10	800      	1.4*3600      0.2*1e-3
    3	11	800      	1.3*3600      0.2*1e-3
    4	12	800      	1.2*3600      0.2*1e-3
    5	13	800      	1.2*3600      0.2*1e-3
    ];
si.node=[
    % node	load (%)	Tsmin	Tsmax	Trmin Trmax	flowrate(kg/h)
    0	0	60	110	20	60	2.5*3600
    1	0	60	110	20	60	2.4*3600
    2	0	60	110	20	60	2.3*3600
    3	0	60	110	20	60	2.2*3600
    4	0	60	110	20	60	2.0*3600
    5	0	60	110	20	60	1.9*3600
    6	0	60	110	20	60	1.5*3600
    7	0.1	60	110	20	60	1.7*3600
    8	0.1	60	110	20	60	1.6*3600
    9	0.1	60	110	20	60	1.5*3600
    10	0.1	60	110	20	60	1.4*3600
    11	0.2	60	110	20	60	1.3*3600
    12	0.2	60	110	20	60	1.2*3600
    13	0.2	60	110	20	60	1.2*3600
    ];

HL=[0.642 0.652 0.642 0.631 0.668 0.722 0.802 0.909 0.989 0.995 1 0.936 0.882 0.882 0.963 0.952 0.936 0.920 0.882 0.856 0.802 0.775 0.78 0.742]*1400;%热负荷典型曲线
for t=1:si.Horizon
    si.HL(:,t)=HL(t)*si.node(:,2);%实际热负荷曲线
end
si.Length=si.pipe(:,3);
si.SPFrate=si.pipe(:,4);
si.RPFrate=si.pipe(:,4);
si.lambda=si.pipe(:,5);
si.TSmin=si.node(:,3)*1;
si.TSmax=si.node(:,4)*1;
si.TRmin=si.node(:,5)*1;
si.TRmax=si.node(:,6)*1;
si.NFrate=si.node(:,7);

%热网位置  电网位置  min  max 
EB=[
    1	2	0	200
%     1	22	0	200
%     1	25	0	200
    ];
si.NumEB=1;
si.EBlocat=EB(:,2);
si.PEBmin=zeros(si.NumEn,1);si.PEBmin(si.EBlocat)=EB(:,3);
si.PEBmax=zeros(si.NumEn,1);si.PEBmax(si.EBlocat)=EB(:,4);