args <- commandArgs()
# define arguments
setwd <- args[6]
index <- as.numeric(args[7])
npc <- as.numeric(args[8])
nfolds <- as.numeric(args[9])
kernel <- args[10]
niter <- as.numeric(args[11])
trace <- as.numeric(args[12])

cat("setwd: ",setwd,"\n")
cat("index: ", index,"\n")
cat("npc: ",npc,"\n")
cat("kernel: ",kernel,"\n")
cat("niter: ",niter,"\n")
cat("trace: ",trace,"\n")

cat("load libraries \n")
library(tidyverse)
library(sgmeth2)

dfpath <- paste(setwd,"temp/df.txt",sep="")
parampath <- paste(setwd, "temp/param.txt",sep="")
glpath <- paste(setwd, "temp/gl.txt",sep="")
df <- read.table(file=dfpath, header=T)
paramgrid <- read.table(file=parampath, header=T)
ind.names <- rownames(df)
group.list <- read.table(file=glpath,header=T) |> as.matrix() |> as.vector()

#sspca.obj <- cv.partition.SSPCA(arg.sparse=paramgrid[index,],df.partition=df,npc=npc,n.folds=nfolds,sparsity.type="sumabs",sumabsv=NULL,kernel=kernel,niter=niter,trace=trace)
sgspca.obj <- cv.partition.sparse_group(arg.group=paramgrid[index,],df.partition=df,npc=npc,n.folds=nfolds,groups=group.list,kernel=kernel,ind.names=ind.names,niter=niter,trace=trace)
fpath <- paste(setwd,"temp/cv_outputs/job_",index,".txt",sep="")
data.obj <- data.frame(job=index,fold=paramgrid[index,1],group=paramgrid[index,2],alpha=paramgrid[index,3],cv.metric=sgspca.obj)
write.table(data.obj,file=fpath,quote=F,row.names=F,col.names=T)
