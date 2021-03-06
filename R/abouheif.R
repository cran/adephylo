#' Abouheif's test based on Moran's I
#' 
#' The test of Abouheif (1999) is designed to detect phylogenetic
#' autocorrelation in a quantitative trait. Pavoine \emph{et al.} (2008) have
#' shown that this tests is in fact a Moran's I test using a particular
#' phylogenetic proximity between tips (see details). The function
#' \code{abouheif.moran} performs basically Abouheif's test for several traits
#' at a time, but it can incorporate other phylogenetic proximities as well.\cr
#' 
#' Note that the original Abouheif's proximity (Abouheif, 1999; Pavoine
#' \emph{et al.} 2008) unifies Moran's I and Geary'c tests (Thioulouse \emph{et
#' al.} 1995).\cr
#' 
#' \code{abouheif.moran} can be used in two ways:\cr - providing a data.frame
#' of traits (\code{x}) and a matrix of phylogenetic proximities (\code{W})\cr
#' - providing a \linkS4class{phylo4d} object (\code{x}) and specifying the
#' type of proximity to be used (\code{method}).
#' 
#' \code{W} is a squared symmetric matrix whose terms are all positive or
#' null.\cr
#' 
#' \code{W} is firstly transformed in frequency matrix A by dividing it by the
#' total sum of data matrix : \deqn{a_{ij} =
#' \frac{W_{ij}}{\sum_{i=1}^{n}\sum_{j=1}^{n}W_{ij}}}{a_ij = W_ij / (sum_i
#' sum_j W_ij)} The neighbouring weights is defined by the matrix \eqn{D =
#' diag(d_1,d_2, \ldots)} where \eqn{d_i = \sum_{j=1}^{n}W_{ij}}{d_i = sum_j
#' W_ij}. For each vector x of the data frame x, the test is based on the Moran
#' statistic \eqn{x^{t}Ax}{t(x)Ax} where x is D-centred.
#' 
#' @param x a data frame with continuous variables, or a \linkS4class{phylo4d}
#' object (i.e. containing both a tree, and tip data). In the latter case,
#' \code{method} argument is used to determine which proximity should be used.
#' @param W a \emph{n} by \emph{n} matrix (\emph{n} being the number rows in x)
#' of phylogenetic proximities, as produced by \code{\link{proxTips}}.
#' @param method a character string (full or unambiguously abbreviated)
#' specifying the type of proximity to be used. By default, the proximity used
#' is that of the original Abouheif's test. See details in
#' \code{\link{proxTips}} for information about other methods.
#' @param f a function to turn a distance into a proximity (see
#' \code{\link{proxTips}}).
#' @param nrepet number of random permutations of data for the randomization
#' test
#' @param alter a character string specifying the alternative hypothesis, must
#' be one of "greater" (default), "less" or "two-sided"
#' @return Returns an object of class \code{krandtest} (randomization tests
#' from ade4), containing one Monte Carlo test for each trait.
#' @author Original code from ade4 (gearymoran function) by Sebastien Ollier\cr
#' Adapted and maintained by Thibaut Jombart <tjombart@@imperial.ac.uk>.
#' @seealso - \code{\link[ade4]{gearymoran}} from the ade4 package\cr -
#' \code{\link[ape]{Moran.I}} from the ape package for the classical Moran's I
#' test. \cr
#' @references
#' 
#' Thioulouse, J., Chessel, D. and Champely, S. (1995) Multivariate analysis of
#' spatial patterns: a unified approach to local and global structures.
#' \emph{Environmental and Ecological Statistics}, \bold{2}, 1--14.
#' @examples
#' 
#' 
#' if(require(ade4)&& require(ape) && require(phylobase)){
#' ## load data
#' data(ungulates)
#' tre <- read.tree(text=ungulates$tre)
#' x <- phylo4d(tre, ungulates$tab)
#' 
#' ## Abouheif's tests for each trait
#' myTests <- abouheif.moran(x)
#' myTests
#' plot(myTests)
#' 
#' ## a variant using another proximity
#' plot(abouheif.moran(x, method="nNodes") )
#' 
#' ## Another example
#' 
#' data(maples)
#' tre <- read.tree(text=maples$tre)
#' dom <- maples$tab$Dom
#' 
#' ## Abouheif's tests for each trait (equivalent to Cmean)
#' W1 <- proxTips(tre,method="oriAbouheif")
#' abouheif.moran(dom,W1)
#' 
#' ## Equivalence with moran.idx
#' 
#' W2 <- proxTips(tre,method="Abouheif")
#' abouheif.moran(dom,W2)
#' moran.idx(dom,W2) 
#' }
#' 
#' @rdname abouheif
#' @import phylobase
#' @import ade4
#' @export abouheif.moran
abouheif.moran <- function (x, W=NULL,
                            method=c("oriAbouheif","patristic","nNodes","Abouheif","sumDD"),
                            f=function(x){1/x}, nrepet=999,alter=c("greater", "less", "two-sided")) {

    ## some checks
    ## if(!require(ade4)) stop("The ade4 package is not installed.")
    alter <- match.arg(alter)
    method <- match.arg(method)

    ## handle W
    if(!is.null(W)){ # W is provided
        if (any(W<0)) stop ("negative terms found in 'W'")
        if (nrow(W) != ncol(W)) stop ("'W' is not squared")
        W <- as.matrix(W)
    } else { # otherwise computed W from x, a phylo4d object
        if(!inherits(x, "phylo4d")) stop("if W is not provided, x has to be a phylo4d object")
        if (is.character(chk <- checkPhylo4(x))) stop("bad phylo4d object: ",chk)
        ##if (is.character(chk <- checkData(x))) stop("bad phylo4d object: ",chk) no longer needed
        W <- proxTips(x, method=method, f=f, normalize="row", symmetric=TRUE)
    }

    nobs <- ncol(W)
    ## W has to be symmetric
    W <- (W + t(W))/2

    ## take data from x if it is a phylo4d
    if(inherits(x, "phylo4d")){
        if (is.character(chk <- checkPhylo4(x))) stop("bad phylo4d object: ",chk)
        ## if (is.character(chk <- checkData(x))) stop("bad phylo4d object: ",chk) : no longer needed
        x <- tdata(x, type="tip")
    }

    ## main computations
    x <- data.frame(x)
    test.names <- names(x)
    x <- data.matrix(x) # convert all variables to numeric type

    if (nrow(x) != nobs) stop ("non convenient dimension")
    nvar <- ncol(x)
    res <- .C("gearymoran",
        param = as.integer(c(nobs,nvar,nrepet)),
        data = as.double(x),
        W = as.double(W),
        obs = double(nvar),
        result = double (nrepet*nvar),
        obstot = double(1),
        restot = double (nrepet),
        PACKAGE="adephylo"
    )
    res <- as.krandtest(obs=res$obs,sim=matrix(res$result,ncol=nvar, byrow=TRUE),
                        names=test.names,alter=alter)
    return(res)
} # end abouheif.moran
