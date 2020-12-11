require 'State'
require 'utils'
require 'OpeningPositionState'

OpenPositionState = {}

extended(OpenPositionState, State)

function OpenPositionState:processState(ticker_config, stocks_data)
    print('- creating stop-loss of level')
    print('if error - write to log, return the same state')
    print('else - return OpeningPositionState')
    
    return OpeningPositionState:new('opening position')
end