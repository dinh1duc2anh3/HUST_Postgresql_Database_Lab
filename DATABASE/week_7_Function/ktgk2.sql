1.Viết hàm nhận 1 tham số là id của 1 album và trả về số lượng bài hát của album đó
    CREATE OR REPLACE FUNCTION CountTracksInAlbum(Album_Id INT)
RETURNS INT AS
$$
DECLARE
    NumberOfTracks INT;
BEGIN
    SELECT COUNT(*) INTO NumberOfTracks
    FROM "Track"
    WHERE "AlbumId" = Album_Id;

    RETURN NumberOfTracks;
END;
$$
LANGUAGE plpgsql;


2.Viết hàm nhận 1 tham số tên quốc gia (country) và trả về danh sách khách hàng ở quốc gia đó


CREATE OR REPLACE FUNCTION GetCustomersByCountry(country_name CHARACTER VARYING)
RETURNS TABLE (
    FirstName CHARACTER VARYING,
    LastName CHARACTER VARYING
) AS
$$
BEGIN
    RETURN QUERY 
    SELECT c."FirstName", c."LastName"
    FROM "Customer" c
    WHERE c."Country" = country_name;
END;
$$
LANGUAGE plpgsql;



 
3.Viết hàm nhận đầu vào là 1 số nguyên N và trả về top N bài hát có doanh thu lớn nhất

CREATE OR REPLACE FUNCTION GetTopSongsByRevenue(N INT)
RETURNS TABLE (
    Name CHARACTER VARYING,
    Revenue NUMERIC
) AS
$$
BEGIN
    RETURN QUERY 
    SELECT 
        t."Name",
        il."UnitPrice" * il."Quantity" AS Revenue
    FROM 
        "InvoiceLine" il
    INNER JOIN "Track" t ON il."TrackId" = t."TrackId"
    ORDER BY Revenue DESC
    LIMIT N;
END;
$$
LANGUAGE plpgsql;

4.4.Thêm cột “amount” vào bảng InvoiceLine để lưu trữ giá phải trả cho bài hát trong hoá đơn. Sau đó viết câu lệnh SQL để tính giá trị cho cột “amount” này (amount = UnitPrice*Quantity). Viết hàm trigger để tự động cập nhập cột amount khi dữ liệu được cập nhập hoặc thêm mới

ALTER TABLE "InvoiceLine"
ADD COLUMN amount NUMERIC;

UPDATE "InvoiceLine"
SET "amount" = "UnitPrice" * "Quantity";


CREATE OR REPLACE FUNCTION update_invoice_line_amount()
RETURNS TRIGGER AS
$$
BEGIN
    NEW.amount = NEW."UnitPrice" * NEW."Quantity";
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER update_invoice_line_amount_trigger
AFTER INSERT OR UPDATE ON "InvoiceLine"
FOR EACH ROW
EXECUTE PROCEDURE update_invoice_line_amount();


Viết hàm trigger để đảm bảo rằng trên bảng Track không có bản ghi nào được thêm mới hay cập nhập mà trường UnitPrice < 0
 CREATE OR REPLACE FUNCTION check_track_unit_price()
RETURNS TRIGGER AS
$$

BEGIN
    IF NEW."UnitPrice" < 0 THEN
        RAISE EXCEPTION 'ERROR: UnitPrice cannot be less than 0';
    END IF;
	
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER check_track_unit_price_trigger
BEFORE INSERT OR UPDATE ON "Track"
FOR EACH ROW
EXECUTE PROCEDURE check_track_unit_price();


Tạo index để tối ưu cho các truy vấn sử dụng trong câu truy vấn/hàm viết ở câu 1,2,3
 1. 

CREATE INDEX ON "Track" ("AlbumId");


2.

CREATE INDEX ON "Customer" ("Country");

3.

CREATE INDEX ON "InvoiceLine" ("UnitPrice");
CREATE INDEX ON "Track" ("TrackId");




