options(stringsAsFactors=F)

args=commandArgs(T)
single_cov= args[1]
anno=args[2]
OutFile=args[3]


library(ggplot2)
library(data.table)
library(reshape2)
library(pheatmap)
library(RColorBrewer)

#df <- fread("chr20_10514700.0-10518966.7222.single.cov")
df <- fread(single_cov)
df_anno <- read.table(anno,sep="\t",row.names = 1)
df_anno <- as.data.frame(df_anno)


Ratio <- function(x,y){x/(x+y)}

df[, Ratio:=Ratio(V6,V7), by=list(V1, V2, V3, V4)]

df$name=paste(df$V1,df$V2,df$V3,sep="_")

df_cast <- dcast(df, V4 ~ name, value.var = c("Ratio"))


A = as.data.frame(df_cast[,-1])
#X <- A[1,]

COA <- function(A){
  
    A <- as.matrix(A)
    sub = matrix(NA, dim(A)[1],dim(A)[1])
    
    B<-A
    colnames(sub)<-as.character(row.names(A))
    row.names(sub)<-as.character(row.names(B))

    for (i in 1:dim(A)[1])
      for (j in 1:dim(B)[1])
      {
        sub [i,j]= abs(A[i,1]-B[j,1])/(A[i,1]+B[j,1]) 
      }
    return(reshape2::melt(sub))
    #write.table(reshap2::melt(sub),file=OutFile,sep="\t",quote=F,col.names=F,row.names=F)
}


D <- apply(A,1,COA)
dfD <- do.call("rbind", D )
df_Dnan <- dfD[!is.na(dfD$value),]
df_bin_sum <- as.data.frame(data.table::dcast(as.data.table(df_Dnan),  Var1 ~  Var2, value.var = c("value"), fun = list( mean)))

row.names(df_bin_sum)<-df_bin_sum$Var1
M<-df_bin_sum[,-1]


#generate gene coa merge
#The cumulative sum
M1 <- 1 - M
out_merge = paste0(single_cov,".merge")
df_anno $V1=row.names(df_anno )
M2<-M1[df_anno [df_anno $V2!="promoter",]$V1,df_anno [df_anno $V2=="promoter",]$V1]
write.table(file=out_merge,rowSums(M2),quote=F,sep="\t",row.names=T,col.names=T)

##----------------------
M <- 0.5 - M
M[lower.tri(M)] <- NA #buquan

my_colors = c("green", "white", "red")
my_colors = c("#39679F", "white", "#F50600")
my_colors = colorRampPalette(my_colors)(200)



#pheatmap(as.matrix(M[1:20,1:20]), border_color = NA, cluster_rows=F, cluster_cols=F, show_rownames = T, show_colnames = T, na_col="grey",color = my_colors,fontsize = 10)


pheatmap(as.matrix(M), border_color = NA, cluster_rows=F, cluster_cols=F, show_rownames = F, show_colnames = F, na_col="grey",file=OutFile,color = my_colors,front.zise=0.8,annotation_col=df_anno, annotation_row=df_anno, cellwidth=10, cellheight=10)

