pragma solidity ^0.4.22;

contract SimpleAuction {

//پارامترها برای حراجی،
// متغیرهای زمانی از نوع مهر زمانی یونیکس هستند یا به ثانیه
    address public beneficiary;
    uint public auctionEnd;

    // وضعیت فعلی حراجی.
    address public highestBidder;
    uint public highestBid;

    // اجازه برداشت به نفر قبلی
    mapping(address => uint) pendingReturns;

    // تغییر وضعیت به پایان یافته در انتها، جلوگیری از هرگونه تغییر در وضعیت
    bool ended;

    // رخدادهایی که پس از هر تغییر فراخوانی میگردند
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    //  توضیحاتی که در ادامه می آیند 
//natspec  
    //نامیده میشود
    // با سه عدد اسلش شناسایی میشوند
    // زمانی که از کاربر برای تایید تراکنش درخواست میشود
    // بشکل متن به او نشان داده میشود

    /// ایجاد مدت زمان حراجی `_biddingTime`
    /// به ثانیه و مورد تایید ذینفع به آدرس
    /// `_beneficiary`.  
    constructor(
        uint _biddingTime,
        address _beneficiary
    ) public {
        beneficiary = _beneficiary;
        auctionEnd = now + _biddingTime;
    }

    /// ثبت درخواست برای شرکت در حراجی
    /// در صورت عدم برنده شدن در حراجی مبلغ بازگردانده میشود
    function bid() public payable {
        // No arguments are necessary, all
        // information is already part of
        // the transaction. The keyword payable
        // is required for the function to
        // be able to receive Ether.

        // Revert the call if the bidding
        // period is over.


        // نیاز به هیچگونه توافقی وجود ندارد،
        // تمام اطلاعات مورد نیاز جزوی از تراکنش می باشد

        // بازگرداندن پس از پایان حراجی 
        require(
            now <= auctionEnd,
            "جراجی پایان یافته است."
        );

        // اگر مبلغ ارسالی کمتر از بالاترین پیشنهاد می باشد
        // مبلغ را بازگردان
        require(
            msg.value > highestBid,
            "مبلغ بیشتری از شما پیشنهاد شده است"
        );

        if (highestBid != 0) {
            // بازگرداندن مبلغ به شکل خودکار به آخرین نفر با دستور زیر
            // highestBidder.send(highestBid)  
            // دارای ریسک امنیتی می باشد
            // به این علت که امکان دارد، قرارداد نا امن دیگری را فراخوانی کند
            // بطور کلی امن تر است اگر اجازه داده شود، افراد خود
            // درخواست بازگرداندن مبلغ را کنند
            pendingReturns[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    /// بازگرداندن مبلغی که تایید نشده است.
    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            // بسیار مهمه که با صفر مقدار دهی شود
            // به این دلیل که درخواست کننده می تواند این تابع را پیش
            // از تکمیل تابع ارسال فراخوانی کند
            // و دوبار یا چند بار درخواست برداشت مبلغ کند
            pendingReturns[msg.sender] = 0;

            if (!msg.sender.send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    /// پایان دادن به حراجی و ارسال مبلغ به ذینفع
    function auctionEnd() public {
        // It is a good guideline to structure functions that interact
        // It is a good guideline to structure functions that interact
        // It is a good guideline to structure functions that interact

        // It is a good guideline to structure functions that interact
        // with other contracts (i.e. they call functions or send Ether)
        // به سه فاز بشکل زیر:
        // 1. توابع کنترلی  - checking conditions
        // 2. عملیات اجرایی  - performing actions 
        // (به احتمال زیاد شرایط را تغییر میدند)
        // 3. تعامل با دیگر قراردادها
        // اگر این فازها با یکدیگر ترکیب (قاطعی) شوند
        // دیگر قراردادهای می توانند با فراخوانی توابع وضعیت درونی
        // قرارداد را تغییر دهند و منجر به پرداخت چندباره مبالغ شوند
         // اگر توابعی که بشکل درونی فراخوانی میشوند، با قراردادهای خارجی
        // تعامل دارند نیز بایستی در فاز تعامل قرار بگیرند
        // و به صرف اینکه از خارج دسترسی ندارند کفایت نمی کند

        // 1. شرطها
        require(now >= auctionEnd, "جراجی کماکان فعال است.");
        require(!ended, "تابع پایان حراجی پیش از این فراخوانی شده است.");

        // 2. تاثیرات
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        // 3. تعاملات
        beneficiary.transfer(highestBid);
    }
}
