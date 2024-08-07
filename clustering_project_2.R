#packages installed
# we need now to call them
library(factoextra)
install.packages("factoextra")

library(corrgram)
library(HDclassif)
library(cluster)
library(mclust)
library(FactMixtAnalysis)
library(nnet)
library(class)
library(tree)
install.packages("readxl")
library(readxl)
install.packages("corrplot")
library(corrplot)




##data procesing 
#lad  Portogal data take only usefull information from the 
#excel,from raw_12 until the column 40 
df <- read_excel("C:/Users/30695/Downloads/PORDATA_By-age-group.xlsx",sheet = "Table"
                 ,range = cell_limits(c(12, 1), c(NA, 40)))
#do the head of data 
head(df)

#convert it to data frame to be easier to manipulate 
data=data.frame(df)

#the columns that i should drop because,it has only na ,it is 
#for the year 2000
dropcolums=c('X2000...3','X2000...5','X2000...7','X2000...9','X2000...11',
             'X2000...13','X2000...15','X2000...17','X2000...19','X2000...21',
             'X2000...23','X2000...25','X2000...27','X2000...29','X2000...31',
             'X2000...33','X2000...35','X2000...37','X2000...39')

#keep only the columns that i want and drop the columns with nas 
data=data[,!names(data) %in% dropcolums]

#give the right colnames base on the excel in the data 
colnames(data)[c(3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21)]=c(
  'Total_2022','0-04_2022','05-09_2022','10-14_2022','15-19_2022','20-24_2022','25-29_2022',
  '30-34_2022','35-39_2022','40-44_2022','45-49_2022','50-54_2022','55-59_2022',
  '60-64_2022','65-69_2022','70-74_2022','75-79_2022','80-84_2022','85_or_more_2022'
)

#change the name from year the territorie 
names(data)[2]='territories'


#convert to numeric  total_2022
data$Total_2022=as.numeric(data$Total_2022)


#convert to numeric 0-04_2022
data$'0-04_2022'=as.numeric(data$'0-04_2022')

#remove th na 
data=na.omit(data)

summary(data[,c(3:21)])

#exclude the total because we whant to group only the age 
data=data[,c(3)]
head(data)

#keep only the municipality because this is 
#geographic.group to do the analysis 
data2=data[data$Geographic.Group=='Municipality',]

head(data2)
dim(data2)


#scale data 
data_scale=scale(data2[,c(3:21)])



#distance 
data_dist=dist(data_scale,method='manhattan')





#linkage method 
hc1=hclust(data_dist,method="ward.D")  ###all variables!
plot(hc1)
rect.hclust(hc1,2)  ## puts a rectiangular arounf the groups



hc2<-hclust(data_dist,method="single")
plot(hc2)
rect.hclust(hc2,3)  ## puts a rectiangular arounf the groups



hc3<-hclust(data_dist,method="average")
plot(hc3)
rect.hclust(hc3,2)  ## puts a rectiangular arounf the groups


hc4<-hclust(data_dist,method="complete")
plot(hc4)
rect.hclust(hc4,2)  ## puts a rectiangular arounf the groups


#### create clasifications
clas1<-cutree(hc1, k=2)
clas2<-cutree(hc2, k=3)
clas3<-cutree(hc3, k=2)
clas4<-cutree(hc4, k=2)




#visulazation of the clusters 
rownames(data_scale)=paste(data2$territories,1:dim(data2)[1],sep='_')
fviz_cluster(list(data=data_scale,cluster=clas1))
fviz_cluster(list(data=data_scale,cluster=clas2))
fviz_cluster(list(data=data_scale,cluster=clas3))
fviz_cluster(list(data=data_scale,cluster=clas4))



str(as.numeric(data2[,c(4:20)]))
######siluente values to see how good the cluster are#########
plot(silhouette(clas1, data_dist))
plot(silhouette(clas2, data_dist))
plot(silhouette(clas3, data_dist))
plot(silhouette(clas4, data_dist))





#####################K-means###############

#calculate how many cluster we need 

set.seed(123)  # for reproducibility

#within sum of squares 
fviz_nbclust(data_scale, kmeans, method = "wss") +
  labs(subtitle = "Elbow method")

#run kmeas cluster with 2 cluster 
km.out=kmeans(data_scale,centers = 2,nstart = 100)

#visulization of the clusters 
km.cluster=km.out$cluster
rownames(data_scale)=paste(data2$territories,1:dim(data2)[1],sep='_')
fviz_cluster(list(data=data_scale,cluster=km.cluster))
##
plot(silhouette(km.cluster, data_dist))
