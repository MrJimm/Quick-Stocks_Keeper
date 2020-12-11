require 'utils'
require 'stocks_utils'

State = {}

function State:core_init(name, key)
  print('State base constructor')
  local obj={}
    obj.name = name
    obj.key = key
  
  function State:getName()
    return self.name
    
  end
  
  function State:processState(ticker_config, stocks_data)
    
  end
  
  setmetatable(obj, self)
  self.__index = self; return obj
  
end
----------------------------------------------------

----------------------------------------------------
ErrorSuspendState = {}

extended(ErrorSuspendState, State)

function ErrorSuspendState:new(pos_key, message_box)
  print("ErrorSuspendState constructor")
  self = self:core_init('ErrorSuspendState', pos_key)
  
  self.messages = message_box
  
  return self
end

function ErrorSuspendState:processState(pos_provider, stocks_provider)
  print('check to reevoke state from pos_provider TODO')
  return self
end
----------------------------------------------------

----------------------------------------------------
OpenPositionState = {}

extended(OpenPositionState, State)

function OpenPositionState:new(pos_key)
  print("OpenPositionState constructor")
  self = self:core_init('OpenPositionState', pos_key)
  
  return self
end

function OpenPositionState:processState(pos_provider, stocks_provider)
  order_res = createStopLimit()
  if order_res['isok'] then
    next_state = EnteringPositionState:new(order_res['order_data'])
  else
    wlog('Error opening position', 2)
    next_state = self
  end  
  
  return next_state
end
----------------------------------------------------

----------------------------------------------------
EnteringPositionState = {}

extended(EnteringPositionState, State)

function EnteringPositionState:new(pos_key, order_data)
  print("EnteringPositionState constructor")
  self = self:core_init('EnteringPositionState', pos_key)
  
  self.order_data = order_data
  return self
end

function EnteringPositionState:checkStopLimitState()
  print('checking stop limit state...\nassuming "executed" TODO')
  return {['state'] = 'executed', ['order_data'] = {['order_id'] = nil} }
end

function EnteringPositionState:checkStopLimitNeedToReset()
  print('checking wether stop limit is needed to reset...\nassuming "false" TODO')
  return false
end

function EnteringPositionState:processState(pos_provider, stocks_provider)
  next_state = self
  
  check_res = self:checkStopLimitState()
  if check_res['state'] == 'active' then
    if self:checkStopLimitNeedToReset(check_res['state']) then
      reset_res = resetStopLimit()
      if reset_res['isok'] then
        self.order_data = reset_res['order_data']
        next_state = self
      else
        wlog('Error resetting order...', 2)
        next_state = self
      end
    else
      next_state = self
    end
    
  elseif check_res['state'] == 'executed' then
    createStopLimit()
    order_res = createStopLimit()
    if order_res['isok'] then
      next_state = HoldPositionState:new(self.pos_key, order_res['order_data'])
    else
      wlog('Error opening position', 2)
      next_state = self
    end  
    
  elseif check_res['state'] == 'declined' then
    wlog('Stop limit order for enter has been declined! what TODO THIS!', 2)
    next_state = ErrorSuspendState.new(self.pos_key)
  else
  end
    
  return next_state
  
end
----------------------------------------------------

----------------------------------------------------
HoldPositionState = {}
extended(HoldPositionState, State)

function HoldPositionState:new(pos_key, pos_stocks_id)
  print("HoldPositionState constructor")
  self = self:core_init('HoldPositionState', pos_key)
  
  self.pos_stocks_id
  
  return self
end

function HoldPositionState:processState(pos_provider, stocks_provider)
    print('- check if stoploss in needed to reset')
    print('if yes - move it and return to the same state')
    print('else if stop limit have been executed - check if position is here. If not - write error. If yes - set stop-loss and go to HavingPosition state')
end
