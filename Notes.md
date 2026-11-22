i am gonna mark the things that i did use chat for it 
##1 & 2 i did highlighted the items and the decisiones i made
  so i am gonna upload the pdf file

##3  
 GUID for members => we needed unique values

 This from chat=>BIGINT for bids=>The mobile app generates the member ID on the phone before the request reaches the server, so the ID must be globally unique without asking the database (UNIQUEIDENTIFIER, with DEFAULT NEWID() when the app sends none). Bids reach hundreds of millions per year; an INT stops at 2,147,483,647, so the counter would overflow within a few years<=

 FLOAT for GPS=> GPS coordinates are approximate measurements with many decimals
 DECIMAL for money=> Money must be exact
 DATETIMEOFFSET for auctions=>cause there is diffirent cities like Dubai,cairo


##4<= from chat
Warehouse needs an FK to Employee (manager) and Employee needs an FK to Warehouse (workplace). Whichever table is created first would reference a table that does not exist yet. So both tables are created without their FKs and the FKs are added afterwards with ALTER TABLE ... ADD CONSTRAINT (task 3.1). For the same reason Warehouse.ManagerId is nullable: a warehouse row cannot be inserted with a manager before the employee row exists, and an employee cannot exist before its warehouse. The manager is filled in afterwards.


##5 choosing parent (has primary key) before child(has the forgein key)
City=>Member=>Wallet=>Warehouse =>Employee=>Category=>Item=>ItemPhoto=>Auction=>Bid=>Marketing.AuctionFollower

##6
  3.4 renaming Capacity => Error : cannot be renamed because it participates in 
                                    enforced dependencies 
                                    sol : Drop the constraint then rename the column the add the constaint again 

  3.6 error :the CHECK is dependent on the column; ALTER COLUMN failed
            sol:Drop then alter then add check

  3.11 error :DF_Member_IsVerified is dependent on the column 
             sol: drop the default constraint then drop the column
    
    
##7
nums = [1, 2, 3, 4]


| index | nums | prefix | suffix | answer |
|   0   |  1   |    1   | 24     | 24     |
|   1   |   2  |    1   |   12   |   12   |
|   2   |   3  |    2   |   4    |   8    |
|   3   |   4  |    6   |   1    |   6    |
result: [24, 12, 8, 6]