--Create the database name _Vehicles
CREATE DATABASE Vehicles_database;


--use the database with name _Vehicles
USE Vehicles_database


-- Vehicle Table
-- Vehicle category: small(carry 4 people), family(carry up to 7), vans.
CREATE TABLE Vehicle(
	Vehicle_ID INT PRIMARY KEY IDENTITY(1,1),
	Vehicle_name VARCHAR(50) NOT NULL,
	Vehicle_category VARCHAR(50) NOT NULL
);


-- Customers Table 
CREATE TABLE Customers(
	Customer_ID INT PRIMARY KEY IDENTITY(1,1) ,
	First_name VARCHAR(55) NOT NULL,
	Last_name VARCHAR(55) NOT NULL,
	Email VARCHAR(60) ,
	Phone_Number VARCHAR(20) NOT NULL,
);


-- Booking Table
CREATE TABLE Booking(
	Booking_ID INT PRIMARY KEY IDENTITY(1,1),
	Customer_ID INT,
	Vehicle_ID INT,
	Hire_Date DATE,
	Return_Date DATE,
	CONSTRAINT FK_Customer_key FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID),
	CONSTRAINT FK_Vehicle_key FOREIGN KEY (Vehicle_ID) REFERENCES Vehicle(Vehicle_ID)
);


-- Insert Values in Vehicle Table
INSERT INTO Vehicle(Vehicle_name,Vehicle_category) VALUES ('Honda','small')
INSERT INTO Vehicle(Vehicle_name,Vehicle_category) VALUES ('Renu','family')
INSERT INTO Vehicle(Vehicle_name,Vehicle_category) VALUES ('BMW','van')
INSERT INTO Vehicle(Vehicle_name,Vehicle_category) VALUES ('BMW','family')


-- Insert Values in Customers Table
INSERT INTO Customers(First_name,Last_name,Email,Phone_Number) VALUES ('John','Diam','Josha.d@gmail.com',+4082823771)
INSERT INTO Customers(First_name,Last_name,Email,Phone_Number) VALUES ('Jamila','gad','Jamagad@gmail.com',+20808343790)
INSERT INTO Customers(First_name,Last_name,Email,Phone_Number) VALUES ('Josha','Michel','Mijosha@outlook.com',+5108233778)


--- Not to hire a car for a longer than a week constrain
ALTER TABLE Booking
ADD CONSTRAINT Hire_period CHECK(DATEDIFF(day, Hire_Date,Return_Date) <= 7);

-- Insert Values in Booking Table
INSERT INTO Booking(Customer_ID,Vehicle_ID,Hire_Date,Return_Date) VALUES (2,1,'2023-1-20','2023-1-23')
INSERT INTO Booking(Customer_ID,Vehicle_ID,Hire_Date,Return_Date) VALUES (1,2,'2022-12-2','2022-12-5')
INSERT INTO Booking(Customer_ID,Vehicle_ID,Hire_Date,Return_Date) VALUES (3,3,'2022-3-25','2022-3-30')



-- If vehicle is available show customer info it else, add it
-- This can be applied with different ways
DECLARE @Vehicle_ID INT = 4;
DECLARE @Customer_ID INT = 2;
DECLARE @Hire_Date DATE = '2023-12-9';
DECLARE @Return_Date DATE = '2023-12-11';
IF NOT EXISTS(SELECT * FROM Booking WHERE  Vehicle_ID = @Vehicle_ID AND Hire_Date <= @Return_Date AND Return_Date >= @Hire_Date)
	BEGIN
		PRINT 'ADDING TO THE SYSTEM';
		INSERT INTO Booking(Customer_ID, Vehicle_ID, Hire_Date, Return_Date)
		VALUES (@Customer_ID, @Vehicle_ID, @Hire_Date, @Return_Date);
END
ELSE 
	BEGIN
		PRINT 'ALREADY IN THE SYSTEM';
		SELECT * FROM Customers 
		JOIN Booking ON Customers.Customer_ID = Booking.Customer_ID
		WHERE Customers.Customer_ID = @Customer_ID 
	END



-- Booking the Vehicle 7 days in Advance 
DECLARE @BookDate DATE = '2023-02-20';
DECLARE @CustomerID INT = 1;
DECLARE @Vehicle VARCHAR(50) ='small';
IF EXISTS(SELECT * FROM Vehicle WHERE Vehicle_category=@Vehicle AND Vehicle_ID NOT IN (SELECT Vehicle_ID FROM Booking WHERE Hire_Date BETWEEN @BookDate AND DATEADD (day,7,@BookDate) AND Return_Date > @BookDate ) )
		BEGIN 
			INSERT INTO Booking(Customer_ID,Vehicle_ID, Hire_Date, Return_Date) VALUES (@CustomerID, (SELECT TOP 1 Vehicle_ID FROM Vehicle WHERE Vehicle_category = @Vehicle 
				AND Vehicle_ID NOT IN (SELECT Vehicle_ID FROM Booking WHERE Hire_Date BETWEEN @BookDate AND DATEADD(day, 7, @BookDate) AND Return_Date > @BookDate)),  @BookDate, DATEADD(day, 7, @BookDate));
					PRINT 'DONE';
END 
ELSE 
	BEGIN 
		PRINT 'Sorry Not Available';
END



-- Adding Payment  
ALTER TABLE Booking ADD Paid DECIMAL;
UPDATE Booking SET paid = 5000 WHERE Booking_ID = 1;



-- Check Availability By Date
CREATE PROCEDURE CheckDate
@Hire_Date DATE,
@Return_Date DATE
AS 
BEGIN 
	SELECT * FROM Vehicle 
	WHERE NOT EXISTS (SELECT * FROM Booking WHERE Vehicle_ID = Vehicle.Vehicle_ID AND Hire_Date <= @Return_Date  AND Return_Date >= @Hire_Date);
END
GO
EXEC CheckDate '2023-05-01', '2023-05-05';



--Invoice 
CREATE PROCEDURE Invoice
	@Booking_ID INT
AS 
BEGIN 
	SELECT Customers.First_name, Customers.Last_name, Vehicle.Vehicle_name, Vehicle.Vehicle_category, Booking.Hire_Date, Booking.Return_Date,DATEDIFF(day,Hire_Date, Return_Date) AS TotalCost
	FROM Booking join Customers ON Booking.Customer_ID = Customers.Customer_ID
	JOIN Vehicle ON Booking.Vehicle_ID = Vehicle.Vehicle_ID
	WHERE Booking.Booking_ID = @Booking_ID;
END
GO
EXEC Invoice @Booking_ID = 1;



--Confirmation LETTER (added a column that add 1 for customers that need to be confirmed then send a letter)
ALTER TABLE Booking ADD confirmation INT DEFAULT  0;
UPDATE Booking SET confirmation = 1 WHERE Hire_Date > DATEADD(day, 7, GETDATE());
SELECT DISTINCT First_name, Last_name, Email,confirmation FROM Customers JOIN  Booking ON confirmation = 1;
PRINT'CUSTOMERS EMAIL TO SEND CONFOIRMATION';



--- Print Report For a Particular Day
SELECT Booking.Booking_ID, Customers.First_name, Customers.Last_name, Customers.Phone_Number,Booking.paid From Booking
JOIN Customers ON Booking.Customer_ID = Customers.Customer_ID
JOIN Vehicle ON Booking.Booking_ID = Vehicle.Vehicle_ID
WHERE Booking.Hire_Date = '2023-01-20'


