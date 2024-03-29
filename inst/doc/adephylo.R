### R code from vignette source 'adephylo.Rnw'

###################################################
### code chunk number 1: adephylo.Rnw:106-107 (eval = FALSE)
###################################################
## vignette("phylobase")


###################################################
### code chunk number 2: load
###################################################
library(ape)
library(phylobase)
library(ade4)
library(adephylo)
search()


###################################################
### code chunk number 3: adephylo.Rnw:153-154 (eval = FALSE)
###################################################
## ?adephylo


###################################################
### code chunk number 4: adephylo.Rnw:159-160 (eval = FALSE)
###################################################
## help("adephylo", package="adephylo", html=TRUE)


###################################################
### code chunk number 5: readTree
###################################################
data(ungulates)
ungulates$tre
myTree <- read.tree(text=ungulates$tre)
myTree
plot(myTree, main="ape's plotting of a tree")


###################################################
### code chunk number 6: adephylo.Rnw:203-208
###################################################
temp <- as(myTree, "phylo4")
class(temp)
temp <- as(temp, "phylo")
class(temp)
all.equal(temp, myTree)


###################################################
### code chunk number 7: phylo4d
###################################################
ung <- phylo4d(myTree, ungulates$tab)
class(ung)
table.phylo4d(ung)


###################################################
### code chunk number 8: adephylo.Rnw:248-250
###################################################
x <- tdata(ung, type="tip")
head(x)


###################################################
### code chunk number 9: moranI
###################################################
W <- proxTips(myTree, met="Abouheif")
moran.idx(tdata(ung, type="tip")$afbw, W)
moran.idx(tdata(ung, type="tip")[,1], W, addInfo=TRUE)


###################################################
### code chunk number 10: adephylo.Rnw:297-309
###################################################
afbw <- tdata(ung, type="tip")$afbw
sim <- replicate(499, moran.idx(sample(afbw), W)) # permutations
sim <- c(moran.idx(afbw, W), sim)

cat("\n=== p-value (right-tail) === \n")
pval <- mean(sim>=sim[1])
pval

plot(density(sim), main="Moran's I Monte Carlo test for 'bif'") # plot
mtext("Density of permutations, and observation (in red)")
abline(v=sim[1], col="red", lwd=3)



###################################################
### code chunk number 11: abouheif
###################################################
ung.abTests <- abouheif.moran(ung)
ung.abTests
plot(ung.abTests)


###################################################
### code chunk number 12: adephylo.Rnw:353-355
###################################################
hasEdgeLength(ung)
myTree.withBrLe <- compute.brlen(myTree)


###################################################
### code chunk number 13: adephylo.Rnw:361-363
###################################################
myProx <- vcv.phylo(myTree.withBrLe)
abouheif.moran(ung, W=myProx)


###################################################
### code chunk number 14: adephylo.Rnw:390-392
###################################################
x <- as(rtree(5),"phylo4")
plot(x,show.n=TRUE)


###################################################
### code chunk number 15: adephylo.Rnw:395-397
###################################################
x.part <- treePart(x)
x.part


###################################################
### code chunk number 16: adephylo.Rnw:400-402
###################################################
temp <- phylo4d(x, x.part)
table.phylo4d(temp, cent=FALSE, scale=FALSE)


###################################################
### code chunk number 17: adephylo.Rnw:412-414
###################################################
args(treePart)
temp <- phylo4d(x, treePart(x, result="orthobasis") )


###################################################
### code chunk number 18: orthobas1
###################################################
temp <- phylo4d(myTree, treePart(myTree, result="orthobasis") )
par(mar=rep(.1,4))
table.phylo4d(temp, repVar=1:8, ratio.tree=.3)


###################################################
### code chunk number 19: orthogram
###################################################
afbw.ortgTest <- orthogram(afbw, myTree)
afbw.ortgTest


###################################################
### code chunk number 20: adephylo.Rnw:460-461
###################################################
me.phylo(myTree.withBrLe)


###################################################
### code chunk number 21: figFourBas
###################################################
ung.listBas <- list()
ung.listBas[[1]] <- phylo4d(myTree, as.data.frame(me.phylo(myTree.withBrLe, method="patristic")))
ung.listBas[[2]] <- phylo4d(myTree, as.data.frame(me.phylo(myTree, method="nNodes")))
ung.listBas[[3]]<- phylo4d(myTree, as.data.frame(me.phylo(myTree, method="Abouheif")))
ung.listBas[[4]] <- phylo4d(myTree, as.data.frame(me.phylo(myTree, method="sumDD")))
par(mar=rep(.1,4), mfrow=c(2,2))
invisible(lapply(ung.listBas, table.phylo4d, repVar=1:5, cex.sym=.7, show.tip.label=FALSE, show.node=FALSE))


###################################################
### code chunk number 22: lm1
###################################################
afbw <- log(ungulates$tab[,1])
neonatw <- log((ungulates$tab[,2]+ungulates$tab[,3])/2)
names(afbw) <- myTree$tip.label
names(neonatw) <- myTree$tip.label
plot(afbw, neonatw, main="Relationship between afbw and neonatw")
lm1 <- lm(neonatw~afbw)
abline(lm1, col="blue")
anova(lm1)


###################################################
### code chunk number 23: resid
###################################################
resid <- residuals(lm1)
names(resid) <- myTree$tip.label
temp <- phylo4d(myTree,data.frame(resid))
abouheif.moran(temp)
table.phylo4d(temp)


###################################################
### code chunk number 24: adephylo.Rnw:514-521
###################################################
myBasis <- me.phylo(myTree, method="Abouheif")
lm2 <- lm(neonatw~myBasis[,1] + afbw)
resid <- residuals(lm2)
names(resid) <- myTree$tip.label
temp <- phylo4d(myTree,data.frame(resid))
abouheif.moran(temp)
anova(lm2)


###################################################
### code chunk number 25: adephylo.Rnw:547-552
###################################################
W <- proxTips(myTree, method="Abouheif", sym=FALSE)
lagNeonatw <- W %*% neonatw
lm3 <- lm(neonatw ~ lagNeonatw + afbw)
resid <- residuals(lm3)
abouheif.moran(resid,W)


###################################################
### code chunk number 26: pca1
###################################################
f1 <- function(x){
    m <- mean(x,na.rm=TRUE)
    x[is.na(x)] <- m
    return(x)
}

data(maples)
traits <- apply(maples$tab, 2, f1)
pca1 <- dudi.pca(traits, scannf=FALSE, nf=1)
barplot(pca1$eig, main="PCA eigenvalues", col=heat.colors(16))


###################################################
### code chunk number 27: pca2
###################################################
tre <- read.tree(text=maples$tre)
W <- proxTips(tre)
myComp <- data.frame(PC1=pca1$li[,1], lagPC1=W %*% pca1$li[,1])
myComp.4d <- phylo4d(tre, myComp)
nodeLabels(myComp.4d) <- names(nodeLabels(myComp.4d))
table.phylo4d(myComp.4d)


###################################################
### code chunk number 28: aboutest
###################################################
myTest <- abouheif.moran(myComp[,1], W=W)
plot(myTest, main="Abouheif's test using patristic proximity")
mtext("First principal component - maples data", col="blue", line=1)


###################################################
### code chunk number 29: loadings
###################################################
ldgs <- pca1$c1[,1]
plot(ldgs, type="h", xlab="Variable", xaxt="n", ylab="Loadings")
s.label(cbind(1:31, ldgs), lab=colnames(traits), add.p=TRUE, clab=.8)
temp <- abs(ldgs)
thres <- quantile(temp, .75)
abline(h=thres * c(-1,1), lty=2, col="blue3", lwd=3)
title("Loadings for PC1")
mtext("Quarter of most contributing variables indicated in blue", col="blue")


