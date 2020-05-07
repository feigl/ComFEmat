%% plot table from Comsol optimization
% 20200430 Kurt Feigl

% read the tables
% cd /Volumes/GoogleDrive/My Drive/comsol_trials4/LdM
%read_comsol_tables

close all
nf=0;
fileNameBIG = 'read_comsol_tables_BIG.csv'

TBIG = readtable(fileNameBIG);


% sort
[ObjectiveVals,iSort] = sort(TBIG.Objective,'ascend');
TBIG = TBIG(iSort,:);

% calculate dates in years
% first inflection point
y1 = 2007.0672 + years(seconds(table2array(TBIG(:,4)))); TBIG = [TBIG, table(y1rel,'VariableNames', {'y1'})];
% start of second injection
y2 = 2007.0672 + years(seconds(table2array(TBIG(:,5)))); TBIG = [TBIG, table(y2rel,'VariableNames', {'y2'})];

% get the names of the variables
varNames = TBIG.Properties.VariableNames
[nrows,ncols] = size(TBIG);

% Q1(y1), Q2(y2), Q3(tend) are volumetric flow rates in m^3/s
% for this run tend = 2019.8
% final run will be tend = 2020.3


% print the optimal solution
Tbest=TBIG(1,:)

%% extract relevant columns
iCols = [1:3,10,11];

% make correlation plot
nf=nf+1;figure;
%corrplot(TBIG,'varNames',TBIG.Properties.VariableNames);
[Rcorr,Pvalue,Handles] =corrplot(TBIG(:,iCols),'varNames',varNames(iCols));
% Try not to interpret underscores as Latex subscripts. Fails. 
% for i=1:numel(iCols)
%     for j=1:numel(iCols)
%         ax1 = get(Handles(i,j),'Parent');
%         ax1.XLabel.Interpreter='none';
%     end
% end
savefig(sprintf('%sFig%03d.fig',mfilename,nf));
print(gcf,'-dpdf',sprintf('%sFig%03d.pdf',mfilename,nf),'-r600','-fillpage','-painters');


%% plot objective function for each parameter
yvals = log10(ObjectiveVals);
ylab = 'log10(Objective)';
for i=iCols
    nf=nf+1;figure;
    hold on;
    xvals = table2array(TBIG(:,i));
    xsig = nanstd(xvals)
    plot(xvals,yvals,'k+');
    plot(xvals(1),yvals(1),'ro','MarkerSize',12,'MarkerFaceColor','r');
    errorbar(xvals(1),yvals(1),[],[],xsig,xsig,'r');
    
    xlabel(TBIG.Properties.VariableNames{i});
    ylabel(ylab,'Interpreter','none');
    title(sprintf('%s %10.4f +/- %10.4f',TBIG.Properties.VariableNames{i} ...
        ,xvals(i),xsig));
    savefig(sprintf('%sFig%03d.fig',mfilename,nf));
    print(gcf,'-dpdf',sprintf('%sFig%03d.pdf',mfilename,nf),'-r600','-fillpage','-painters');
end
   

%% plot trade-off for each parameter
for i=iCols
    for j=i:i-1
        nf=nf+1;figure;
        hold on;
        xvals = table2array(TBIG(:,i));
        yvals = table2array(TBIG(:,j));
        
        plot(xvals,yvals,'r.'); % ,'MarkerSize',12,'MarkerFaceColor','r');
        %errorbar(xvals(1),yvals(1),[],[],xsig,xsig,'r');
        
        xlabel(TBIG.Properties.VariableNames{i},'Interpreter','none');
        ylabel(TBIG.Properties.VariableNames{j},'Interpreter','none');
        savefig(sprintf('%sFig%03d.fig',mfilename,nf));
        print(gcf,'-dpdf',sprintf('%sFig%03d.pdf',mfilename,nf),'-r600','-fillpage','-painters');
    end
end
 