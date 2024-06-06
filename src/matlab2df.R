# Install library IF NEEDED
#install.packages( "R.matlab" )

# Load library
#library(R.matlab)

# Convert *.mat file into R list
## REPLACE BY PATH TO YOUR *.m FILE ##
pert_ls <- readMat( "/media/marcos/Data/Artigos/IA_tax/mat/totalPertDesc.m" )

# Convert list to data fame
## REPLACE ARGUMENT PASSED TO 'nrow' BY THE TOTAL NUMBER OF COLUMNS (SAMPLES) IN YOUR ORIGINAL STRUCT ##
## RETURNED BY THE FUNCTION columns(struct) IN OCTAVE ##
pert_df <- data.frame( matrix( unlist( pert_ls ), nrow = 46500, byrow = T ), stringsAsFactors = FALSE )

# Rename columns
no_cols <- ncol( pert_df )
group_cols <- paste( "group", 1:(no_cols - 6), sep = "_" )
all_cols <- c( "imgclass", "individual", "scale", "replicate", "group", "exp", group_cols )
i <- 1:no_cols
names(pert_df)[i] <- all_cols[i]

# Save to *.csv file
## REPLACE BY PATH TO YOUR *.csv FILE ##
write.table ( 
    pert_df, 
    file = "/media/marcos/Data/Artigos/IA_tax/csv/pert_desc.csv",
    append = FALSE,
    quote = TRUE, 
    sep = ";",
    eol = "\n", 
    na = "undef",
    dec = ".", 
    col.names = TRUE,
    qmethod = c( "double" ),
    fileEncoding = "UTF-8"
)
