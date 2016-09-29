#======================================================================================================
# Install data.table package

install.packages("data.table")

#======================================================================================================
# Load data.table package

library(data.table)

#======================================================================================================
# Build data.table from scratch

transactions <- data.table(
  TransactionID = seq(1, 10),
  TransactionDate = as.Date(c("2011-06-16", "2012-08-26", "2013-12-30", "2011-05-26", "2014-04-24", 
                              "2016-05-08", "2010-08-21", "2013-12-23", "2013-06-06", "2015-04-24")),
  ProductID = c(3L, 2L, 4L, 4L, 2L, 4L, 2L, 5L, 4L, 4L), 
  UserID = c(3L, 1L, 3L, 3L, 1L, 5L, 1L, 2L, 2L, 3L), 
  Quantity = c(0L, 3L, 0L, 0L, 3L, 4L, 0L, 6L, 0L, 3L)
)

#======================================================================================================
# Read datasets from CSV

# Load transactions from CSV
transactions <- fread("Data/transactions.csv")

#======================================================================================================
# Meta info

# Full summary
str(transactions)

# How many rows?
nrow(transactions)

# How many columns?
ncol(transactions)

# Get the row names
rownames(transactions)

# Get the column names
colnames(transactions)

# Change the name of column "Quantity" to "Quant"
setnames(transactions, "Quantity", "Quant")
setnames(transactions, "Quant", "Quantity")  # change it back

# Change the name of columns ProductID and UserID to PID and UID respectively
setnames(transactions, c("ProductID", "UserID"), c("PID", "UID"))
setnames(transactions, c("PID", "UID"), c("ProductID", "UserID"))  # change them back

#======================================================================================================
# Row subsetting

# Subset rows 1, 3, and 6
transactions[c(1,3,6)]

# Subset rows exlcuding 1, 3, and 6
transactions[!c(1,3,6)]

# Subset the first 3 rows
transactions[1:3]
head(transactions, 3)

# Subset rows excluding the first 3 rows
transactions[-1:-3]
tail(transactions, -3)

# Subset the last 2 rows
indices <- seq(nrow(transactions) - 1, nrow(transactions), by=1)
transactions[indices]
tail(transactions, 2)

# Subset rows excluding the last 2 rows
transactions[!indices]
tail(transactions, -2)

# Subset rows where Quantity > 1
transactions[Quantity > 1]

# Subset rows where UserID = 2
transactions[UserID == 2]

# Subset rows where Quantity > 1 and UserID = 2
transactions[Quantity > 1 & UserID == 2]

# Subset rows where Quantity + UserID is > 3
transactions[Quantity + UserID > 3]

# Subset rows where an external vector, foo, is TRUE
foo <- c(TRUE, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE)
transactions[foo]

# Subset rows where an external vector, bar, is positive
bar <- c(1, -3, 2, 2, 0, -4, -4, 0, 0, 2)
transactions[sign(bar) == 1]

# Subset rows where foo is TRUE or bar is negative
transactions[foo | sign(bar) == -1]

# Subset the rows where foo is not TRUE and bar is not negative
transactions[!foo & sign(bar) > -1]

#======================================================================================================
# Column subsetting

# Subset by columns 1 and 3
transactions[, c(1, 3), with=FALSE]

# Subset by columns TransactionID and TransactionDate
transactions[, list(TransactionID, TransactionDate)]
transactions[, .(TransactionID, TransactionDate)]  # short-hand version of line above

# Subset rows where TransactionID > 5 and subset columns by TransactionID and TransactionDate
transactions[TransactionID > 5, list(TransactionID, TransactionDate)]

# Subset columns defined by a vector of columm names
print_cols <- c("TransactionID", "UserID", "Quantity")
transactions[, print_cols, with=FALSE]

# Subset columns defined by a vector of column names
print_cols <- c("TransactionID", "UserID", "Quantity")
transactions[, print_cols, with=FALSE]

# Subset columns excluding a vector of column names
transactions[, !print_cols, with=FALSE]

#======================================================================================================
# Extract a vector

# Get the 2nd column
transactions[[2]]

# Get the ProductID vector
transactions$ProductID

# Get the ProductID vector using a variable
col <- "ProductID"
transactions[[col]]

#======================================================================================================
# Inserting & Updating Values

# Convert the TransactionDate column to type Date
transactions[, TransactionDate := as.Date(TransactionDate)]

# Insert a new column, Foo = UserID + ProductID
transactions[, Foo := UserID + ProductID]

# Subset rows where TransactionID is even and set Foo = NA
transactions[TransactionID %% 2 == 0, Foo := NA]

# Add 100 to each TransactionID
transactions[, TransactionID := 100 + TransactionID]
transactions[, TransactionID := TransactionID - 100]  # revert to original IDs

# Insert a column indicating each row number
transactions[, RowIdx := .I]

# Insert columns indicating the rank of each Quantity, minimum Quantity and maximum Quantity
transactions[, `:=`(QuantityRk=frank(Quantity, ties.method = "average"), QuantityMin=min(Quantity), QuantityMax=max(Quantity))]

# Remove column Foo
transactions[, Foo := NULL]

# Remove multiple columns RowIdx, QuantityRk, and RowIdx
transactions[, c("RowIdx", "QuantityRk", "QuantityMin", "QuantityMax") := NULL]

#======================================================================================================
# Ordering the rows

# Order by TransactionID descending
transactions <- transactions[order(-TransactionID)]
transactions <- transactions[order(TransactionID)]  # change it back

# Order by UserID descending, TransactionDate descending
setorderv(transactions, c("Quantity", "TransactionDate"), order=c(1, -1))
setorder(transactions, TransactionID)  # change it back

#======================================================================================================
# Group By & Aggregation

# Count the number of transactions per user
transactions[, list(Transactions = .N), by=UserID]

# Count the number of transactions & average Quantity per user
transactions[, list(Transactions = .N, QuantityAvg = mean(Quantity)), by=UserID]

# Count the transactions per year
transactions[, list(Transactions = .N), by=year(TransactionDate)]

# Count the transactions per (user, year) pair
transactions[, list(Transactions = .N), by=list(UserID, TransactionYear=year(TransactionDate))]

# Count the number of unique users which made a transaction per year (this is called chaining)
transactions[, list(Transactions = .N), by=list(UserID, TransactionYear=year(TransactionDate))][, list(Users=.N), by=TransactionYear]

# For each user in transactions, get the date of the transaction which had the most quantity
transactions[, list(TargetDate=TransactionDate[which.min(Quantity)], MinQuantity=min(Quantity)), by=UserID]

# Insert a column in transactions indicating the number of transactions per user
transactions[, UserTransactions := .N, by=UserID]

# Insert columns in transactions indicating the first transaction date and last transaction date per user
transactions[, `:=`(FirstTransactionDate=min(TransactionDate), LastTransactionDate=max(TransactionDate)), by=UserID]

# For each transaction, get the date of the previous transaction made by the same user
setorder(transactions, "UserID", "TransactionDate")
transactions[, PrevTransactionDate := c(as.Date(NA), head(TransactionDate, -1)), by=UserID]

#======================================================================================================
# Joins

# Read datasets from CSV
users <- fread("Data/users.csv")
sessions <- fread("Data/sessions.csv")
products <- fread("Data/products.csv")
transactions <- fread("Data/transactions.csv")

# Set the first UserID in transactions to NA
transactions[1, UserID := NA]

# Convert date columns to Date type
users[, `:=`(Registered = as.Date(Registered), Cancelled = as.Date(Cancelled))]
sessions[, SessionDate := as.Date(SessionDate)]
transactions[, TransactionDate := as.Date(TransactionDate)]

#--------------------------------------------------
# Basic Joins

# Join users to transactions, keeping all rows from transactions and only matching rows from users (left join)
users[transactions, on="UserID"]

# Which transactions aren't tied to a user in users
transactions[!users, on="UserID"]

# Join users to transactions, keeping only rows from transactions and users that match via UserID (inner join)
users[transactions, on="UserID", nomatch=0]

# Join users to transactions, displaying all matching rows AND all non-matching rows (full outer join)
merge(users, transactions, by="UserID", all=TRUE)

# Determine which transactions each user made on the same day he/she registered
transactions[users, on=c("UserID", "TransactionDate"="Registered")]

# Build a dataset with every possible (UserID, ProductID) pair (cross join)
CJ(UserID=users$UserID, ProductID=products$ProductID)

# Determine how much quantity of each product was purchased by each user
transactions[, list(Quantity=sum(Quantity)), by=list(UserID, ProductID)][CJ(UserID=users$UserID, ProductID=products$ProductID), on=c("UserID", "ProductID")]

# For each user, get each possible pair of pair transactions (TransactionID1, TransactionID2)
t1 <- transactions[, list(UserID, TransactionID1=TransactionID)]
t2 <- transactions[, list(UserID, TransactionID2=TransactionID)]
t1[t2, on="UserID", allow.cartesian=TRUE]

# Join each user to his/her first occuring transaction in the transactions table
transactions[users, on="UserID", mult="first"]

#--------------------------------------------------
# Rolling Joins

# Determine the ID of the last session which occured prior to (and including) the date of each transaction per user
sessions[, RollDate := SessionDate]
transactions[, RollDate := TransactionDate]
setkey(sessions, "UserID", "RollDate")
setkey(transactions, "UserID", "RollDate")
sessions[transactions, roll=TRUE]

# Determine the ID of the first session which occured after (and including) the date of each transaction per user
sessions[, RollDate := SessionDate]
transactions[, RollDate := TransactionDate]
setkey(sessions, "UserID", "RollDate")
setkey(transactions, "UserID", "RollDate")
sessions[transactions, roll=-Inf]

#--------------------------------------------------
# Non-equi joins

# Determine the first transaction that occured for each user prior to (and including) his/her Cancelled date
setorder(transactions, "TransactionDate")
transactions[users, on=list(UserID, TransactionDate <= Cancelled), mult="first"]

# Get all transactions where TransactionDate is after the user's Cancellation Date
users[transactions, on=list(UserID, Cancelled < TransactionDate), nomatch=0]

#--------------------------------------------------
# Join + Update

# Insert the price of each product in the transactions dataset (join + update)
transactions[products, ProductPrice := Price, on="ProductID"]

# Insert the number of transactions each user made into the users dataset
users[transactions, on="UserID", Transactions := .N, by=UserID]

#--------------------------------------------------
# setkey and secondary indexing

# Set the key of Transactions as UserID  ()
setkey(transactions, "UserID")
transactions  # notice rows are now sorted by UserID

# View the key of transactions
key(transactions)

# Set the key of users as UserID and join to transactions, matching rows only (inner join)
setkey(users, "UserID")
transactions[users, nomatch=0]

# Set ProductID as the key of transactions and products without re-ordering the rows, then join matching rows only
setkey(transactions, "ProductID", physical=FALSE)
setkey(products, "ProductID", physical=FALSE)
transactions[products, nomatch=0]

# Set each ID column as a secondary join index
setindex(transactions, "TransactionID")
setindex(transactions, "ProductID")
setindex(transactions, "UserID")
setindex(products, "ProductID")
setindex(users, "UserID")

# View indices
indices(transactions)
indices(products)
indices(users)

# Inner join between users, transactions, and products
users[transactions, on="UserID"][products, on="ProductID"]  # Note that having the pre-computed secondary indices makes this faster

#======================================================================================================
# Reshaping Data

# Read datasets from CSV
users <- fread("Data/users.csv")
transactions <- fread("Data/transactions.csv")

# Convert date columns to Date type
users[, `:=`(Registered = as.Date(Registered), Cancelled = as.Date(Cancelled))]
transactions[, TransactionDate := as.Date(TransactionDate)]

# Add column TransactionWeekday as a factor with levels Saturday through Friday
transactions[, TransactionWeekday := factor(weekdays(TransactionDate), levels=c("Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"))]

#--------------------------------------------------
# Convert data from wide format to tall format

# One-hot encode Weekday (i.e. convert data from tall to wide, where each possible weekday is a column)
dcast(transactions, TransactionID ~ TransactionWeekday, value.var="TransactionWeekday", fun.aggregate=function(x) length(x))

#--------------------------------------------------
# Convert data from tall format to wide format

# Build a data.table with columns {UserID, ActionType, Date} where ActionType is either "Registered" or "Cancelled" and Date is the corresponding date value
melt(users, id.vars="UserID", measure.vars=c("Registered", "Cancelled"), variable.name="ActionType", value.name="Date")

#======================================================================================================
# To Do

# Get rows which contain at least 1 NA value
# Get rows which contain at least 1 NA value within a subset of columns

# Get rows which contain all NA values
# Get rows which contain all NA values within a subset of columns

# Get the max value per row
# Get the max value per row within a subset of columns