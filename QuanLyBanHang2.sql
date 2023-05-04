create database if not exists QuanLyBanHang2;

use QuanLyBanHang2;

create table if not exists QuanLyBanHang2.Customer
(
    cID   int primary key auto_increment,
    cName varchar(25) not null,
    cAge  tinyint     not null
);

create table if not exists QuanLyBanHang2.Order
(
    oID         int primary key auto_increment,
    cID         int      not null,
    oDate       datetime not null,
    oTotalPrice int,
    constraint fk_Order_cID foreign key (cID) references Customer (cID)
);

create table if not exists QuanLyBanHang2.Product
(
    pID    int primary key auto_increment,
    pName  varchar(25) not null,
    pPrice int         not null
);

create table if not exists QuanLyBanHang2.OrderDetail
(
    oID   int,
    pID   int,
    odQTY int not null,
    constraint fk_OD_oID foreign key (oID) references `Order` (oID),
    constraint fk_OD_pID foreign key (pID) references `Product` (pID)
);

insert into QuanLyBanHang2.Customer (cID, cName, cAge)
values (1, 'Minh Quan', 10),
       (2, 'Ngoc Oanh', 20),
       (3, 'Hong Ha', 50);

insert into `Order` (oID, cID, oDate)
values (1, 1, '2006/3/21'),
       (2, 2, '2006/3/23'),
       (3, 1, '2006/3/16');

insert into Product (pID, pName, pPrice)
values (1, 'May Giat', 3),
       (2, 'Tu Lanh', 5),
       (3, 'Dieu Hoa', 7),
       (4, 'Quat', 1),
       (5, 'Bep Dien', 2);

insert into OrderDetail (oID, pID, odQTY)
values (1, 1, 3),
       (1, 3, 7),
       (1, 4, 2),
       (2, 1, 1),
       (3, 1, 8),
       (2, 5, 4),
       (2, 3, 3);

# 2
select *
from `Order`;

# 3
select pName, pPrice
from Product
where pPrice = (select max(pPrice) from Product);

# 4
select C.cName, P.pName
from Customer C
         join QuanLyBanHang2.`Order` O on C.cID = O.cID
         join QuanLyBanHang2.OrderDetail OD on O.oID = OD.oID
         join QuanLyBanHang2.Product P on P.pID = OD.pID;

# 5
select Customer.cName
from Customer
         left join QuanLyBanHang2.`Order` O on Customer.cID = O.cID
where O.cID is null;

# 6
select OD.oID, O.oDate, od.odQTY, P.pName, P.pPrice
from OrderDetail OD
         join QuanLyBanHang2.Product P on P.pID = OD.pID
         join QuanLyBanHang2.`Order` O on O.oID = OD.oID
         join QuanLyBanHang2.Product P2 on P2.pID = OD.pID;

# 7
select OD.oID, O.oDate, sum(P.pPrice * OD.odQTY) as Total
from OrderDetail OD
         join QuanLyBanHang2.Product P on P.pID = OD.pID
         join QuanLyBanHang2.`Order` O on O.oID = OD.oID
         join QuanLyBanHang2.Product P2 on P2.pID = OD.pID
group by OD.oID;

# 8 .Create View
create view Sales_View as
select sum(OD.odQTY * P.pPrice) as Sales
from OrderDetail OD
         join QuanLyBanHang2.Product P on P.pID = OD.pID;

select *
from Sales_View;

# 9. Disable Key
set foreign_key_checks = 0;

# 10. Create Trigger
delimiter
//
-- Create the Trigger called 'cusUpdate'"
create trigger cusUpdate
    after update
    on Customer
    for each row
begin
    -- Trigger Content in here
    if NEW.cID != OLD.cID then
        update `Order` set cID = NEW.cID where cID = OLD.cID;
    end if;
end;
//
delimiter ;

drop trigger if exists cusUpdate;

update Customer
set cID = 15
where cName = 'Ngoc Oanh';

# 11
delimiter
//
-- Create the Procedure called 'delProduct()'"
create procedure delProduct(
    in productName varchar(25)
)
begin
    -- Content for Procedure 'delProduct()' in here
    delete from OrderDetail where pID = (select Product.pID from Product where pName = productName);
    delete from Product where pName = productName;
end;
//
delimiter ;

call delProduct('Quat');

set sql_safe_updates = 0;