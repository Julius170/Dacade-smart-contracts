// SPDX-License-Identifier: MIT 



pragma solidity ^0.8.7;

contract Rentals_Dapp {

    address public owner;
    uint256 private counter;

// This will initilaize the owner of the contract on deployment.
    constructor() {
        counter = 0;
        owner = msg.sender;
     }

// This data-structure will keep record of the rental detaials 
    struct rentalInfo {
        string name;
        string city;
        string apartment_Description;
        string imgUrl;
        uint256 maxGuests;
        uint256 pricePerDay;
        string[] datesBooked;
        uint256 id;
        address renter;
    }

// This event will be called when someone want to rent an appartment  
    event rentalCreated (
        string name,
        string city,
        string apartment_Description,
        string imgUrl,
        uint256 maxGuests,
        uint256 pricePerDay,
        string[] datesBooked,
        uint256 id,
        address renter
    );

// This event will keep record of the date and ew other details attached to the rental details
    event newDatesBooked (
        string[] datesBooked,
        uint256 id,
        address booker,
        string city,
        string imgUrl 
    );

// This mapping function will map the rental info struct to a number, to keep record of the details in an array off rentalIds 
    mapping(uint256 => rentalInfo) rentals;
    uint256[] public rentalIds;

// This function will enable the owner of the function to put up new rentals with the rental details 
    function addRentals(
        string memory name,
        string memory city,
        string memory apartment_Description,
        string memory imgUrl,
        uint256 maxGuests,
        uint256 pricePerDay,
        string[] memory datesBooked
    ) public {
        require(msg.sender == owner, "Only owner of smart contract can put up rentals");
        rentalInfo storage newRental = rentals[counter];
        newRental.name = name;
        newRental.city = city;
        newRental.apartment_Description;
        newRental.imgUrl = imgUrl;
        newRental.maxGuests = maxGuests;
        newRental.pricePerDay = pricePerDay;
        newRental.datesBooked = datesBooked;
        newRental.id = counter;
        newRental.renter = owner;
        rentalIds.push(counter);
        emit rentalCreated(
                name, 
                city, 
                apartment_Description, 
                imgUrl, 
                maxGuests, 
                pricePerDay, 
                datesBooked, 
                counter, 
                owner);
        counter++;
    }

// This function will check a specific rental detail and return false if the apartment has been rented else True  
    function checkBookings(uint256 id, string[] memory newBookings) private view returns (bool){
        
        for (uint i = 0; i < newBookings.length; i++) {
            for (uint j = 0; j < rentals[id].datesBooked.length; j++) {
                if (keccak256(abi.encodePacked(rentals[id].datesBooked[j])) == keccak256(abi.encodePacked(newBookings[i]))) {
                    return false;
                }
            }
        }
        return true;
    }


    function addDatesBooked(uint256 id, string[] memory newBookings) public payable {
        
        require(id < counter, "No such Rental");
        require(checkBookings(id, newBookings), "Already Booked For Requested Date");
        require(msg.value == (rentals[id].pricePerDay * 1 ether * newBookings.length) , "Please submit the asking price in order to complete the purchase");
    
        for (uint i = 0; i < newBookings.length; i++) {
            rentals[id].datesBooked.push(newBookings[i]);
        }

        payable(owner).transfer(msg.value);
        emit newDatesBooked(newBookings, id, msg.sender, rentals[id].city,  rentals[id].imgUrl);
    
    }

// This function simply takes in a number as an Id and return the rental details if they exist.
    function getRental(uint256 id) public view returns (string memory, uint256, string[] memory){
        require(id < counter, "No such Rental");

        rentalInfo storage s = rentals[id];
        return (s.name,s.pricePerDay,s.datesBooked);
    }
}
