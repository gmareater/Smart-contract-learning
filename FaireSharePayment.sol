pragma solidity ^0.4.0;
contract FaireSharePayment
{
    //آدرس 5 پرسنل توافق شده
    address[] employees = [0xA9001d90528C544171398A20F05b1bC25a54c187
    ,0xFbf21C1F49533BbeF7a84c8f5CAA038Fa329B2f8
    ,0x6B22c95F3F2895EB8f43C95B9bbDc2087C606F19
    ,0xC0314E3362A21c24383A3e717A6dB4c99f9DeF7b
    ,0xEFfF3F193e76aB4419a44330B847a954C4b13224];
    //کل مبلغ دریافتی
    uint totalAmount =0;
    //میزان پرداختی به هر کاربر
    mapping(address => uint) payments;
    // سازنده
    constructor () payable public
    {
        updateTotalPayment();
    }
    // تابع پیش فرض یا بدون نام قرارداد
    function () payable public
    {
        updateTotalPayment();
    } 

    //بروزرسانی مبلغ دریافتی
    function updateTotalPayment() internal {
        totalAmount += msg.value;
    }
    //بررسی اینکه آیا فردی که درخواست برداشت وجه کرده است، جزو یکی از 5 پرسنل می باشد
    modifier canWithdraw() {
        bool allow = false;
        for (uint i =0; i < employees.length; i+ )
        {
            if(employees[i] == msg.sender)
            allow = true;
        }
        require(allow);
        _;
    }

    //برداشت وجه
    function withdraw() canWithdraw public {
        uint allocatedAmount = totalAmount / employees.length;
        uint withdrawAmount = payments[msg.sender];
        uint amount = allocatedAmount - withdrawAmount;
        payments[msg.sender] = withdrawAmount+ amount;
        if(amount > 0)
        msg.sender.transfer(amount);
    }
}
