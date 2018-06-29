pragma solidity 0.4.24;
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
contract Ownable {
  address internal owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  function Ownable() {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a / b;
    return c;
  }
  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}






contract BasicToken is ERC20Basic {
  using SafeMath for uint256;
  mapping(address => uint256) balances;
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
}


contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract StandardToken is ERC20, BasicToken {
  mapping (address => mapping (address => uint256)) allowed;
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    uint256 _allowance = allowed[_from][msg.sender];
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
  function increaseApproval (address _spender, uint _addedValue)
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
  function decreaseApproval (address _spender, uint _subtractedValue)
    returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  bool public mintingFinished = false;
  modifier canMint() {
    require(!mintingFinished);
    _;
  }
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(msg.sender, _to, _amount);
    return true;
  }
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
  function burnTokens(uint256 _unsoldTokens) onlyOwner public returns (bool) {
    totalSupply = SafeMath.sub(totalSupply, _unsoldTokens);
  }
}




contract Pausable is Ownable {
  event Pause();
  event Unpause();
  bool public paused = false;
  modifier whenNotPaused() {
    require(!paused);
    _;
  }
  modifier whenPaused() {
    require(paused);
    _;
  }
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}
contract Crowdsale is Ownable, Pausable {

  using SafeMath for uint256;
  MintableToken internal token;
  address internal wallet;
  uint256 public rate;
  uint256 internal weiRaised;
  uint256 public ICOstartTime;
  uint256 public ICOEndTime;
  uint256 public totalSupply = SafeMath.mul(1000000000 , 1 ether);
  uint256 public icoSupply = SafeMath.mul(92242535, 1 ether);
  // SUPPLIES :: START
  uint256 public publicSupply = SafeMath.mul(400000000, 1 ether);
  uint256 public teamFounderSupply = SafeMath.mul(250000000, 1 ether);
  uint256 public companyVestingSupply = SafeMath.mul(250000000, 1 ether);
  uint256 public advisorSupply = SafeMath.mul(30000000, 1 ether);
  uint256 public bountySupply = SafeMath.mul(10000000, 1 ether);
  uint256 public rewardsSupply = SafeMath.mul(60000000, 1 ether);
  // SUPPLIES :: END
  uint256 public tier_bonus_suply = SafeMath.mul(35454734,1 ether);
  uint256 public teamFounderTimeLock;
  uint256 public companyVestingTimeLock;
  uint256 public advisorTimeLock;
  uint internal founderCounter = 0;
  uint internal advisorCounter = 0;
  uint internal companyCounter = 0;
  bool public checkBurnTokens;
  bool public checkAlocatedBurn;
  bool public tier_gold_completed;
  bool public tier_silver_completed;
  bool public tier_bronze_completed;
  bool public tier_copper_completed;
  uint256 public tier_gold_slots = 0;
  uint256 public tier_silver_slots = 0;
  uint256 public tier_bronze_slots = 0;
  uint256 public tier_copper_slots = 0;

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != 0x0);
    token = createTokenContract();
    ICOstartTime = _startTime;
    ICOEndTime = _endTime;
    rate = _rate;
    wallet = _wallet;

    teamFounderTimeLock = SafeMath.add(ICOEndTime, 360 days);
    companyVestingTimeLock = SafeMath.add(ICOEndTime, 360 days);
    advisorTimeLock = SafeMath.add(ICOEndTime, 180 days);

    checkBurnTokens = false;
    checkAlocatedBurn = false;


    tier_gold_completed = false;
    tier_silver_completed = false;
    tier_bronze_completed = false;
    tier_copper_completed = false;
  }
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }
  function privateTokens(uint256 weiAmount, uint256 tokens) internal returns (uint256) {
    if((SafeMath.sub(2,tier_gold_slots) >= SafeMath.div(weiAmount,100000000000000000)) && (weiAmount - (100000000000000000 * (SafeMath.div(weiAmount,100000000000000000))) == 0) && tier_gold_completed == false)
    {
      tokens = tierGoldTokens(weiAmount,tokens);
    }
    else if((SafeMath.sub(5,tier_silver_slots) >= SafeMath.div(weiAmount,100000000000000000)) && (weiAmount - (100000000000000000 * (SafeMath.div(weiAmount,100000000000000000))) == 0) && tier_silver_completed == false && tier_gold_completed == true)
    {
      tokens = tierSilverTokens(weiAmount,tokens);
    }
    else if((SafeMath.sub(25,tier_bronze_slots) >= SafeMath.div(weiAmount,100000000000000000)) && (weiAmount - (100000000000000000 * (SafeMath.div(weiAmount,100000000000000000))) == 0) && tier_bronze_completed == false  && tier_silver_completed == true  && tier_gold_completed == true)
    {
      tokens = tierBronzeTokens(weiAmount,tokens);
    }
    else if((SafeMath.sub(100,tier_copper_slots) >= SafeMath.div(weiAmount,100000000000000000)) && (weiAmount - (100000000000000000 * (SafeMath.div(weiAmount,100000000000000000))) == 0) && tier_copper_completed == false && tier_bronze_completed == true  && tier_silver_completed == true  && tier_gold_completed == true)
    {
      tokens = tierCopperTokens(weiAmount,tokens);
    }
    else{
      tokens = icoTokens(weiAmount, tokens);
    }
     return tokens;
  }
  function tierGoldTokens(uint256 weiAmount, uint256 tokens) internal returns (uint256)
  {
    require(tier_gold_completed == false);
    require(tier_gold_slots < 2);
    if((SafeMath.sub(2,tier_gold_slots) >= SafeMath.div(weiAmount,100000000000000000)) && (weiAmount - (100000000000000000 * (SafeMath.div(weiAmount,100000000000000000))) == 0))
    {
      tokens = SafeMath.add(tokens, weiAmount.mul(rate));
      tier_gold_slots = SafeMath.add(tier_gold_slots,SafeMath.div(weiAmount,100000000000000000));
    }
    if(tier_gold_slots == 2)
    {
      tier_gold_completed = true;
      return tokens;
    }
    else
    {
      return tokens;
    }
  }
  function tierSilverTokens(uint256 weiAmount, uint256 tokens) internal returns (uint256)
  {
    require(tier_silver_completed == false);
    require(tier_silver_slots < 5);
    if((SafeMath.sub(5,tier_silver_slots) >= SafeMath.div(weiAmount,100000000000000000)) && (weiAmount - (100000000000000000 * (SafeMath.div(weiAmount,100000000000000000))) == 0))
    {
      tokens = SafeMath.add(tokens, weiAmount.mul(rate));
      tier_silver_slots = SafeMath.add(tier_silver_slots,SafeMath.div(weiAmount,100000000000000000));
    }
    if(tier_silver_slots == 5)
    {
      tier_silver_completed = true;
      return tokens;
    }
    else
    {
      return tokens;
    }
  }
  function tierBronzeTokens(uint256 weiAmount, uint256 tokens) internal returns (uint256)
  {
    require(tier_bronze_completed == false);
    require(tier_bronze_slots < 25);
    if((SafeMath.sub(25,tier_bronze_slots) >= SafeMath.div(weiAmount,100000000000000000)) && (weiAmount - (100000000000000000 * (SafeMath.div(weiAmount,100000000000000000))) == 0))
    {
      tokens = SafeMath.add(tokens, weiAmount.mul(rate));
      tier_bronze_slots = SafeMath.add(tier_bronze_slots,SafeMath.div(weiAmount,100000000000000000));
    }
    if(tier_bronze_slots == 25)
    {
      tier_bronze_completed = true;
      return tokens;
    }
    else
    {
      return tokens;
    }
  }
  function tierCopperTokens(uint256 weiAmount, uint256 tokens) internal returns (uint256)
  {
    require(tier_copper_completed == false);
    require(tier_copper_slots < 100);
    if((SafeMath.sub(100,tier_copper_slots) >= SafeMath.div(weiAmount,100000000000000000)) && (weiAmount - (100000000000000000 * (SafeMath.div(weiAmount,100000000000000000))) == 0))
    {
      tokens = SafeMath.add(tokens, weiAmount.mul(rate));
      tier_copper_slots = SafeMath.add(tier_copper_slots,SafeMath.div(weiAmount,100000000000000000));
    }
    if(tier_copper_slots == 100)
    {
      tier_copper_completed = true;
      return tokens;
    }
    else
    {
      return tokens;
    }
  }
  function icoTokens(uint256 weiAmount, uint256 tokens) internal returns (uint256)
  {
    require((weiAmount >= 100000000000000000) && (weiAmount <=1000000000000000000000));
    require(icoSupply > 0);
    tokens = SafeMath.add(tokens, weiAmount.mul(rate));
    require(icoSupply >= tokens);
    icoSupply = icoSupply.sub(tokens);
    publicSupply = publicSupply.sub(tokens);
    return tokens;
  }
  function () payable
  {
    buyTokens(msg.sender);
  }
  function buyTokens(address beneficiary) whenNotPaused public payable {
    require(beneficiary != 0x0);
    require(validPurchase());
    uint256 weiAmount = msg.value;
    uint256 tokens = 0;
    if((weiAmount >= 100000000000000000) && (tier_gold_slots < 2 || tier_silver_slots < 5 || tier_bronze_slots < 25 || tier_copper_slots < 100))
    {
      tokens = privateTokens(weiAmount, tokens);
    }
    else
    {
      tokens = icoTokens(weiAmount, tokens);
    }
    weiRaised = weiRaised.add(weiAmount);
    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    forwardFunds();
  }
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= ICOstartTime && now <= ICOEndTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }
  function hasEnded() public constant returns (bool) {
      return now > ICOEndTime;
  }
  function getTokenAddress() onlyOwner public returns (address) {
    return token;
  }
}


contract Allocations is Crowdsale {
function bountyDrop(address[] recipients, uint256[] values) onlyOwner public {
for (uint256 i = 0; i < recipients.length; i++) {
  values[i] = SafeMath.mul(values[i], 1 ether);
  require(bountySupply >= values[i]);
  bountySupply = SafeMath.sub(bountySupply,values[i]);
  token.mint(recipients[i], values[i]);
  }
}
function grantAdvisorToken(address beneficiary ) onlyOwner  public {
  require((advisorCounter < 6) && (advisorTimeLock < now));
  advisorTimeLock = SafeMath.add(advisorTimeLock, 30 days);
  token.mint(beneficiary,SafeMath.div(advisorSupply, 6));
  advisorCounter = SafeMath.add(advisorCounter, 1);
}
function grantTeamFounderToken(address teamfounderAddress) onlyOwner  public {
  require((founderCounter < 36) && (teamFounderTimeLock < now));
  teamFounderTimeLock = SafeMath.add(teamFounderTimeLock, 30 days);
  token.mint(teamfounderAddress,SafeMath.div(teamFounderSupply, 36));
  founderCounter = SafeMath.add(founderCounter, 1);
}

function grantCompanyToken(address companyAddress) onlyOwner  public {
  require((companyCounter < 36) && (companyVestingTimeLock < now));
  companyVestingTimeLock = SafeMath.add(companyVestingTimeLock, 30 days);
  token.mint(companyAddress,SafeMath.div(companyVestingSupply, 36));
  companyCounter = SafeMath.add(companyCounter, 1);
}
function transferRewardsFunds(address[] recipients, uint256[] values) onlyOwner  public {
for (uint256 i = 0; i < recipients.length; i++) {
  values[i] = SafeMath.mul(values[i], 1 ether);
  require(rewardsSupply >= values[i]);
  rewardsSupply = SafeMath.sub(rewardsSupply,values[i]);
  token.mint(recipients[i], values[i]);
}
}
function transferFunds(address[] recipients, uint256[] values) onlyOwner  public {
require(!checkBurnTokens);
for (uint256 i = 0; i < recipients.length; i++) {
  values[i] = SafeMath.mul(values[i], 1 ether);
  require(publicSupply >= values[i]);
  publicSupply = SafeMath.sub(publicSupply,values[i]);
  token.mint(recipients[i], values[i]);
}
}
function bonusTransfers(address[] recipients, uint256[] values) onlyOwner  public {
require(!checkBurnTokens);
for (uint256 i = 0; i < recipients.length; i++) {
  values[i] = SafeMath.mul(values[i], 1 ether);
  require(tier_bonus_suply >= values[i]);
  tier_bonus_suply = SafeMath.sub(tier_bonus_suply,values[i]);
  token.mint(recipients[i], values[i]);
}
}
function burnToken() onlyOwner  public returns (bool) {
  require(hasEnded());
  require(!checkBurnTokens);
  token.burnTokens(icoSupply);
  totalSupply = SafeMath.sub(totalSupply, icoSupply);
  publicSupply = 0;
  icoSupply = 0;
  checkBurnTokens = true;
  return true;
}

function allocatedTokenBurn () onlyOwner public returns (bool)
{
  require(!checkAlocatedBurn);
  require(hasEnded());
  token.burnTokens(advisorSupply);
  token.burnTokens(bountySupply);
  totalSupply = SafeMath.sub(totalSupply, advisorSupply);
  totalSupply = SafeMath.sub(totalSupply, bountySupply);
  advisorSupply = 0;
  bountySupply = 0;

  checkAlocatedBurn = true;
  return true;
}
}



contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;
  uint256 internal cap;
  function CappedCrowdsale(uint256 _cap) {
    require(_cap > 0);
    cap = _cap;
  }
  function validPurchase() internal constant returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }
  function hasEnded() public constant returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }
}






contract FinalizableCrowdsale is Crowdsale {
  using SafeMath for uint256;
  bool isFinalized = false;
  event Finalized();
  function finalizeCrowdsale() onlyOwner public {
    require(!isFinalized);
    require(hasEnded());
    finalization();
    Finalized();
    isFinalized = true;
    }
  function finalization() internal {
  }
}



contract RefundVault is Ownable {
  using SafeMath for uint256;
  enum State { Active, Refunding, Closed }
  mapping (address => uint256) public deposited;
  address public wallet;
  State public state;
  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);
  function RefundVault(address _wallet) public {
    require(_wallet != 0x0);
    wallet = _wallet;
    state = State.Active;
  }
  function deposit(address investor) onlyOwner public payable {
    require(state == State.Active);
    deposited[investor] = deposited[investor].add(msg.value);
  }
  function close() onlyOwner public {
    require(state == State.Active);
    state = State.Closed;
    Closed();
    wallet.transfer(this.balance);
  }
  function enableRefunds() onlyOwner public {
    require(state == State.Active);
    state = State.Refunding;
    RefundsEnabled();
  }
  function refund(address investor) public {
    require(state == State.Refunding);
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    investor.transfer(depositedValue);
    Refunded(investor, depositedValue);
  }
}

contract RefundableCrowdsale is FinalizableCrowdsale {
  using SafeMath for uint256;
  uint256 internal goal;
  RefundVault private vault;
  function RefundableCrowdsale(uint256 _goal) public {
    require(_goal > 0);
    vault = new RefundVault(wallet);
    goal = _goal;
  }
  function forwardFunds() internal {
    vault.deposit.value(msg.value)(msg.sender);
  }
  function claimRefund() public {
    require(isFinalized);
    require(!goalReached());
    vault.refund(msg.sender);
  }
  function finalization() internal {
    if (goalReached()) {
      vault.close();
    } else {
      vault.enableRefunds();
    }
    super.finalization();
  }
  function goalReached() public view returns (bool) {
    return weiRaised >= goal;
  }
  function getVaultAddress() onlyOwner public returns (address) {
    return vault;
  }
}


contract ZillosToken is MintableToken {
  string public constant name = "Zillios Token";
  string public constant symbol = "ZLST";
  uint8 public constant decimals = 18;
  uint256 public totalSupply = SafeMath.mul(1000000000 , 1 ether);
}
contract ZillosCrowdsale is Crowdsale, CappedCrowdsale, RefundableCrowdsale, Allocations {
    function ZillosCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _cap, uint256 _goal, address _wallet) public
    CappedCrowdsale(_cap)
    FinalizableCrowdsale()
    RefundableCrowdsale(_goal)
    Crowdsale(_startTime, _endTime, _rate, _wallet)
    {
    }
    function createTokenContract() internal returns (MintableToken) {
        return new ZillosToken();
    }
}
