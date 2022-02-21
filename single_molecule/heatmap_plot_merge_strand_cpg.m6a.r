options(stringsAsFactors=F)
args  <- commandArgs(TRUE)

File <- args[1]
cpgFile <- args[2]
OutFile <- args[3]

library(reshape2)
library(pheatmap)
library(RColorBrewer)
library(ComplexHeatmap)
library(data.table)
library(dplyr)

if(FALSE){


File <- "chr20_52319078-52320690.single.m6A.cov"
cpgFile <- "chr20_52319078-52320690.single.cpg.cov"
OutFile <- "./"
File="/zfswh1/BC_RD_P0/P19Z12200N0089/2021/cut_modify/6.panel3/chrY_58971901-58973432/chrY_58971901-58973432.single.xls"
#/ifswh1/BC_PUB/biosoft/pipeline/RNA/10x/Seurat_V3.0/software/R
}



df<-fread(File)
#df_f <- filter(df, V8 == "+")[,c(1,2,3,4,7)]
df_f <-df[,c(1,2,3,4,7)]

df$name <- paste(df$V1,df$V2,df$V3,sep="_")
df$cov <- df$V5+ df$V6

df_cov<-aggregate(df$cov, by=list(position=df$name), FUN=mean)
cov_name<-df_cov$position
df_cov<-df_cov[,-1]
names(df_cov) <- cov_name
#df2<-acast(df,id~variable,fill=NA)
column_ha=HeatmapAnnotation(cov = anno_barplot(df_cov))


#筛选大于50bin的reads
df_f_filter <- df_f

fun_filter_read <- function(df_strand){
T_df_strand <- table(df_strand$V4)
bin_number<-dim(unique(df_strand[,c(1,2,3)]))[1]
#T_df_name <- names(T_df_strand[!T_df_strand  <bin_number*0.9])
T_df_name <- names(T_df_strand[!T_df_strand  <bin_number*1])
#T_df_name <- names(T_df_strand[!T_df_strand  <bin_number*0])

df_strand_filter  <- df_strand[df_strand$V4  %in% T_df_name,]
return (df_strand_filter)
}


df_f_filter <- fun_filter_read(df_f)

df_f_cast <- acast(df_f_filter,V1+V2+V3~V4,fill=-1)

F_pdf_name  = paste0(OutFile,"no_strand.m6A.pdf")


if(FALSE){
cat (R_pdf_name)
heatmap_plot <- function(R_pdf_name,strand_cast){
pdf(R_pdf_name)
column_ha=HeatmapAnnotation(cov = anno_barplot(df_cov))

colours=colorRampPalette(c("#03F602","#070000","#F90000"))(100)
Heatmap(t(strand_cast), col=colours, cluster_column = FALSE,  top_annotation = column_ha ,name = "Methylation ratio", row_names_gp = gpar(fontsize = 2),column_names_gp = gpar(fontsize = 2))

dev.off()
}
}

#--------------------------------------------------
if(FALSE){
pdf(R_pdf_name)
column_ha=HeatmapAnnotation(cov = anno_barplot(df_cov))

#colours=colorRampPalette(c("#03F602","#070000","#F90000"))(100)
my_colors = c("green", "white", "red")
my_colors = colorRampPalette(my_colors)(500)

Heatmap(t(df_r_cast), col=my_colors , cluster_column = FALSE,  top_annotation = column_ha ,name = "Methylation ratio", row_names_gp = gpar(fontsize = 2),column_names_gp = gpar(fontsize = 2))

dev.off()
}
#--------------------------------------------------
my_colors = c("#2470A2", "white", "#C03B2D")
my_colors = colorRampPalette(my_colors)(500)

#pdf(F_pdf_name,30,10)
column_ha=HeatmapAnnotation(cov = anno_barplot(df_cov))

colours=colorRampPalette(c("#03F602","#070000","#F90000"))(100)
#限制大小
# Heatmap(t(df_f_cast), col=my_colors, cluster_column = FALSE,  top_annotation = column_ha ,name = "Methylation ratio", row_names_gp = gpar(fontsize = 2),column_names_gp = gpar(fontsize = 2),width = ncol(t(df_f_cast))*unit(4, "mm"), height = nrow(t(df_f_cast))*unit(4, "mm"))
pdf(F_pdf_name)
heat <- Heatmap(t(df_f_cast), col=my_colors, cluster_column = FALSE,  top_annotation = column_ha ,name = "Methylation ratio")
heat
dev.off()

###Cpg
single_name <- row.names(t(df_f_cast)[row_order(heat),])

df1<-fread(cpgFile)
#df_f <- filter(df, V8 == "+")[,c(1,2,3,4,7)]
df_f1 <-df1[,c(1,2,3,4,7)]

df_f_cast1 <- acast(df_f1 ,V1+V2+V3~V4,fill=NA)
cpg_single_df <- t(df_f_cast1)[single_name,]
F_pdf_name  = paste0(OutFile,"no_strand.cpg.pdf")
pdf(F_pdf_name)

#Heatmap(cpg_single_df, col=my_colors, cluster_row = FALSE, cluster_column = FALSE ,name = "Methylation ratio")
Heatmap(cpg_single_df, col=my_colors, cluster_row = FALSE, cluster_column = FALSE ,name = "Methylation ratio", na_col = "grey")
dev.off()







