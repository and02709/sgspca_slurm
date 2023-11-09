args <- commandArgs()
# define arguments
setwd <- args[6]
xfile <- args[7]
yfile <- args[8]
npc <- as.numeric(args[9])
nfolds <- as.numeric(args[10])
groupdf <- args[11]
gparams <- args[12]
alphas <- args[13]
kernel <- args[14]
niter <- as.numeric(args[15])
trace <- as.numeric(args[16])
balance <- as.numeric(args[17])
cat("setwd: ",setwd,"\n")
cat("xfile: ", xfile,"\n")
cat("yfile: ",yfile,"\n")
cat("npc: ",npc,"\n")
cat("nfolds: ",nfolds,"\n")
cat("groups: ",groupdf,"\n")
cat("gparams: ",gparams,"\n")
cat("alphas: ",alphas,"\n")
cat("kernel: ",kernel,"\n")
cat("niter: ",niter,"\n")
cat("trace: ",trace,"\n")
cat("balance: ",balance,"\n")
## check parameters
cat("read in arguments \n")
cat("about to read in data \n")
X <- read.table(xfile)
Y <- read.table(yfile)
X <- as.matrix(X)
Y <- as.matrix(Y)
groups <- read.table(file=groupdf, header=F) |> as.matrix() |> as.vector()
nonzero.groups <- read.table(file=gparams, header=F) |> as.matrix() |> as.vector()
alpha <- read.table(file=alphas, header=F) |> as.matrix() |> as.vector()
cat("read in data \n")
n <- nrow(X)
p <- ncol(X)
cat("label data \n")
colnames(X) <-paste0("x",c(1:p))
colnames(Y) <- "y"

unique.groups <- unique(groups)
num.group <- length(unique.groups)
if(sum((nonzero.groups-floor(nonzero.groups))==0) != length(nonzero.groups)) stop("Must specify integer groups")
if(min(nonzero.groups) < 1) stop("Must specify minimum number of nonzero groups as at least 1")
if(max(nonzero.groups) > num.group) stop("Cannot have more nonzero groups than total number of groups")

if(min(alpha < 0)) stop("Must have non-negative alpha values")
if(max(alpha >= 1)) stop("Must have alpha values less than 1")

rownames(X) <- c(1:n)
rownames(Y) <- c(1:n)
ind.names <- rownames(X)

if(kernel!="linear" && kernel!="delta") stop("Please select a valid kernel")
df <- data.frame(Y,X)
num.nz.gr <- length(nonzero.groups)
if(kernel=="delta" && part.balance){
  df.partition <- groupdata2::fold(data=df,k=nfolds,cat_col = "y")
} else{
  df.partition <- groupdata2::fold(data=df,k=nfolds)
}
cat("partitioned data \n")
fold.arg <- c(1:nfolds)
param.grid <- expand.grid(fold.arg,nonzero.groups,alpha)
colnames(param.grid) <- c("fold.arg","nonzero.groups","alpha")
cat("set up argument grid \n")
fpath <- paste(setwd,"temp",sep="")
dfpath <- paste(fpath,"/df.txt",sep="")
parampath <- paste(fpath,"/param.txt",sep="")
gpath <- paste(fpath,"/garg.txt",sep="")
glpath <- paste(fpath,"/gl.txt",sep="")
apath <- paste(fpath,"/alphas.txt",sep="")
cat("set up paths \n")
write.table(df.partition,file=dfpath,row.names = T,col.names = T,quote=F)
cat("save partitioned data \n")
write.table(param.grid,file=parampath,row.names = F,col.names = T,quote=F)
cat("save parameter grid \n")
write.table(nonzero.groups,file=gpath,quote=F)
cat("save group param argument vector \n")
write.table(groups,file=glpath,quote=F)
cat("save group index vector \n")
write.table(alpha,file=apath,quote=F)
cat("save alpha param argument vector \n")