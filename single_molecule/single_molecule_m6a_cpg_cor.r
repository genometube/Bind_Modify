args=commandArgs(T)

input= args[1]
out_prefix=args[2]


#packages = c("data.table", "ggplot2", "scales","dplyr","ggpubr","reshape2")
packages = c( "ggplot2","dplyr","ggpubr","reshape2")
sapply(packages, require, character.only = T)



# input="region_all.cov"
df <- read.table(input,header=T)

colnames(df ) <- c("chr_name","bin_start","bin_end","read_name",    "methy_count","unmethy_count","methy_ratio","type")

m6a_cpg_df <- df %>%
  group_by(read_name , type) %>% 
  summarise_at(vars(methy_count, unmethy_count ), sum)

m6a_cpg_df <- m6a_cpg_df[m6a_cpg_df$methy_count+m6a_cpg_df$unmethy_count >0,]
m6a_cpg_df$ratio <- m6a_cpg_df$methy_count/(m6a_cpg_df$methy_count + m6a_cpg_df$unmethy_count)

m6a_cpg_df_count <- m6a_cpg_df %>% select(,c(read_name, type,methy_count)) 
m6a_cpg_df_ratio <- m6a_cpg_df %>% select(,c(read_name, type, ratio)) 



m6a_cpg_df_count_cast <- as.data.frame(acast(m6a_cpg_df_count,read_name~type))
m6a_cpg_df_ratio_cast <- as.data.frame(acast(m6a_cpg_df_ratio,read_name~type))


pp <- m6a_cpg_df_count_cast
pp_ratio <- m6a_cpg_df_ratio_cast

plt2 = ggplot(pp, aes(x = m6A, y = CpG)) +
  geom_point() +
  #geom_smooth(formula = y ~ x, method = "lm", se = F, color = "red", linetype = 2, size = 2) +
 stat_cor(aes(x =  m6A, y = CpG))+
  theme_classic()

pdf_name=paste0(out_prefix,"_count.pdf")
pdf(pdf_name)
plt2
dev.off()

plt1 = ggplot(pp_ratio, aes(x = m6A, y = CpG)) +
  geom_point() +
  #geom_smooth(formula = y ~ x, method = "lm", se = F, color = "red", linetype = 2, size = 2) +
  stat_cor(aes(x =  m6A, y = CpG))+
  theme_classic()

pdf_name=paste0(out_prefix,"_ratio.pdf")

pdf(pdf_name)
plt1
dev.off()



###SPLIT stat
### ratio
#<25
pp_ratio$Stat <- NA
pp_ratio[pp_ratio$m6A <= quantile(pp_ratio$m6A)[2],]$Stat<-"Light"
#25-75
pp_ratio[pp_ratio$m6A > quantile(pp_ratio$m6A)[2] &pp_ratio$m6A  <= quantile(pp_ratio$m6A)[4],]$Stat<-"Medium"
#>75
pp_ratio[pp_ratio$m6A > quantile(pp_ratio$m6A)[4] ,]$Stat<-"Heavy"
###
Light <- row.names(pp_ratio[pp_ratio$m6A <= quantile(pp_ratio$m6A)[2],])
Medium <-row.names(pp_ratio[pp_ratio$m6A > quantile(pp_ratio$m6A)[2] &pp_ratio$m6A  <= quantile(pp_ratio$m6A)[4],])

Heavy <- row.names(pp_ratio[pp_ratio$m6A > quantile(pp_ratio$m6A)[4] ,])
###count
pp$Stat <- NA
pp[Light,]$Stat<-"Light"

#25-75
pp[Medium,]$Stat <-"Medium"

#>75
pp[Heavy,]$Stat <-"Heavy"


plt3 = ggplot(pp, aes(x = m6A, y = CpG,color= Stat)) +
  geom_point() +
  #geom_smooth(formula = y ~ x, method = "lm", se = F, color = "red", linetype = 2, size = 2) +
  stat_cor(aes(x =  m6A, y = CpG))+
  theme_classic()

pdf_name=paste0(out_prefix,"_count_split_stat.pdf")

pdf(pdf_name)
plt3
dev.off()



###SD
if(FALSE){
pp_del_na <- as.data.frame(pp[!(is.na(pp$CpG)|is.na(pp$m6A)),])
pp_count <- pp_del_na %>% dplyr::group_by(Stat) %>% dplyr::summarize(
  CpG=sum(CpG),
  m6A=sum(m6A),
  #m6a_SD=sd(m6A),
  #cpg_SD=sd(CpG,na.rm = T),
  cpg_mean=mean(CpG),
  m6A_mean=mean(m6A),
)

###summarize求出来sum与mean一样?
pp_count$sd_m6A <- sd(pp_del_na$m6A)
pp_count$sd_cpg <- sd(pp_del_na$CpG)
pp_count$cpg_mean <- mean(pp_del_na$CpG)
pp_count$m6A_mean <- mean(pp_del_na$CpG)


pp_ratio_del_na2$sd_m6A <- sd(pp_ratio_del_na$m6A)
pp_ratio_del_na2$sd_cpg <- sd(pp_ratio_del_na$CpG)
pp_ratio_del_na2$cpg_mean <- mean(pp_ratio_del_na$CpG)
pp_ratio_del_na2$m6A_mean <- mean(pp_ratio_del_na$CpG)


}






####count
#### ratio
pp_na <- as.data.frame(pp[!(is.na(pp$CpG)|is.na(pp$m6A)),])

#dfout <- merge(
pp_naout <- merge(
  setNames(aggregate(CpG~Stat,pp_na,mean),c("Stat","mean_cpg")),
  setNames(aggregate(CpG~Stat,pp_na,sum),c("Stat","sum_cpg")))

pp_naout <-merge(pp_naout, setNames(aggregate(m6A~Stat,pp_na,mean),c("Stat","mean_m6A")))

pp_naout <-merge(pp_naout,setNames(aggregate(m6A~Stat,pp_na,sum),c("Stat","sum_m6A")))
pp_naout <-merge(pp_naout,setNames(aggregate(m6A~Stat,pp_na,sd),c("Stat","sd_m6A")))

pp_naout <-merge(pp_naout,setNames(aggregate(CpG~Stat,pp_na,sd),c("Stat","sd_cpg"))
)


#### ratio
pp_ratio_del_na <- as.data.frame(pp_ratio[!(is.na(pp_ratio$CpG)|is.na(pp_ratio$m6A)),])


#dfout <- merge(
dfout <- merge(
setNames(aggregate(CpG~Stat,pp_ratio_del_na,mean),c("Stat","mean_cpg")),
setNames(aggregate(CpG~Stat,pp_ratio_del_na,sum),c("Stat","sum_cpg")))

dfout <-merge(dfout, setNames(aggregate(m6A~Stat,pp_ratio_del_na,mean),c("Stat","mean_m6A")))

dfout <-merge(dfout,setNames(aggregate(m6A~Stat,pp_ratio_del_na,sum),c("Stat","sum_m6A")))
dfout <-merge(dfout,setNames(aggregate(m6A~Stat,pp_ratio_del_na,sd),c("Stat","sd_m6A")))

dfout <-merge(dfout,setNames(aggregate(CpG~Stat,pp_ratio_del_na,sd),c("Stat","sd_cpg"))
)


######################################################

if(FALSE){

pp[pp$Stat=="Heavy",]$m6a_SD <- pp2[pp2$Stat=="Heavy",]$m6A
pp[pp$Stat=="Heavy",]$cpg_SD <- pp2[pp2$Stat=="Heavy",]$CpG

pp[pp$Stat=="Medium",]$m6a_SD <- pp2[pp2$Stat=="Medium",]$m6A
pp[pp$Stat=="Medium",]$cpg_SD <- pp2[pp2$Stat=="Medium",]$CpG

pp[pp$Stat=="Light",]$m6a_SD <- pp2[pp2$Stat=="Light",]$m6A
pp[pp$Stat=="Light",]$cpg_SD <- pp2[pp2$Stat=="Light",]$CpG
}
###############################33
####count####
pp_naout$Stat <- factor(pp_naout$Stat,levels = c("Light","Medium","Heavy"))


ppp <- ggplot(data=pp_naout ,aes(x = Stat, y = mean_m6A ))+geom_bar( stat="identity", fill="skyblue", alpha=0.7)+
  geom_errorbar( aes(x=Stat, ymin=mean_m6A-sd_m6A, ymax=mean_m6A+sd_m6A), width=0.4, colour="orange", alpha=0.9, size=1.3)+          
  #stat_cor(aes(x =  Stat, y = m6A_mean,group=Stat))+
  theme_classic()

pdf_name=paste0(out_prefix,"_count_m6A_bar.pdf")
pdf(pdf_name)
ppp
dev.off()

ppp2 <-ggplot(data=pp_naout ,aes(x = Stat, y = mean_cpg ))+geom_bar( stat="identity", fill="skyblue", alpha=0.7)+
  geom_errorbar( aes(x=Stat, ymin=mean_cpg-sd_cpg, ymax=mean_cpg+sd_cpg), width=0.4, colour="orange", alpha=0.9, size=1.3)+          
  #stat_cor(aes(x =  Stat, y = m6A_mean,group=Stat))+
  theme_classic()

pdf_name=paste0(out_prefix,"_count_cpg_bar.pdf")
pdf(pdf_name)
ppp2
dev.off()

###ratio
dfout$Stat <- factor(dfout$Stat,levels = c("Light","Medium","Heavy"))

ppp <- ggplot(data=dfout ,aes(x = Stat, y = mean_m6A ))+geom_bar( stat="identity", fill="skyblue", alpha=0.7)+
  geom_errorbar( aes(x=Stat, ymin=mean_m6A-sd_m6A, ymax=mean_m6A+sd_m6A), width=0.4, colour="orange", alpha=0.9, size=1.3)+          
  #stat_cor(aes(x =  Stat, y = m6A_mean,group=Stat))+
  theme_classic()

pdf_name=paste0(out_prefix,"_ratio_m6A_bar.pdf")
pdf(pdf_name)
ppp 
dev.off()

ppp2 <- ggplot(data=dfout ,aes(x = Stat, y = mean_cpg ))+geom_bar( stat="identity", fill="skyblue", alpha=0.7)+
  geom_errorbar( aes(x=Stat, ymin=mean_cpg-sd_cpg, ymax=mean_cpg+sd_cpg), width=0.4, colour="orange", alpha=0.9, size=1.3)+          
  #stat_cor(aes(x =  Stat, y = m6A_mean,group=Stat))+
  theme_classic()

pdf_name=paste0(out_prefix,"_ratio_cpg_bar.pdf")
pdf(pdf_name)
ppp2
dev.off()

###############################


pdf_name=paste0(out_prefix,"_ratio_m6A_bar.pdf")

pdf(pdf_name)
ppp 
dev.off()


