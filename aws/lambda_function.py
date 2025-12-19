
"""
AWS Lambda function to fetch stock data
This uses Alpha Vantage API (free tier)

Environment Variables needed:
- ALPHA_VANTAGE_API_KEY

Lambda Configuration:
- Runtime: Python 3.11
- Memory: 256 MB
- Timeout: 30 seconds
"""

import json
import os
import requests
from datetime import datetime, timedelta

def lambda_handler(event, context):
    """
    Main Lambda handler
    """
    try:
        # Parse request
        body = json.loads(event.get('body', '{}'))
        symbol = body.get('symbol', 'AAPL')
        interval = body.get('interval', 'daily')
        
        # Get API key from environment
        api_key = os.environ.get('ALPHA_VANTAGE_API_KEY')
        
        if not api_key:
            return error_response('API key not configured', 500)
        
        # Fetch stock data
        stock_data = fetch_stock_data(symbol, api_key, interval)
        
        if not stock_data:
            return error_response('Failed to fetch stock data', 500)
        
        return success_response(stock_data)
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return error_response(str(e), 500)


def fetch_stock_data(symbol, api_key, interval='daily'):
    """
    Fetch stock data from Alpha Vantage
    """
    try:
        # Alpha Vantage API endpoint
        if interval == 'intraday':
            function = 'TIME_SERIES_INTRADAY'
            url = f'https://www.alphavantage.co/query?function={function}&symbol={symbol}&interval=5min&apikey={api_key}'
        else:
            function = 'TIME_SERIES_DAILY'
            url = f'https://www.alphavantage.co/query?function={function}&symbol={symbol}&apikey={api_key}'
        
        response = requests.get(url, timeout=10)
        data = response.json()
        
        # Parse time series data
        time_series_key = list(data.keys())[1] if len(data.keys()) > 1 else None
        
        if not time_series_key or time_series_key not in data:
            return None
        
        time_series = data[time_series_key]
        
        # Convert to our format
        result = {
            'symbol': symbol,
            'timeSeries': [],
            'metadata': {
                'lastRefreshed': data.get('Meta Data', {}).get('3. Last Refreshed', ''),
                'interval': interval
            }
        }
        
        # Get last 30 data points
        for timestamp, values in list(time_series.items())[:30]:
            result['timeSeries'].append({
                'timestamp': timestamp,
                'price': float(values['4. close']),
                'volume': float(values['5. volume']),
                'high': float(values['2. high']),
                'low': float(values['3. low']),
                'open': float(values['1. open']),
                'close': float(values['4. close'])
            })
        
        return result
        
    except Exception as e:
        print(f"Fetch error: {str(e)}")
        return None


def success_response(data):
    """
    Return success response
    """
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key',
            'Access-Control-Allow-Methods': 'GET,POST,OPTIONS'
        },
        'body': json.dumps(data)
    }


def error_response(message, status_code):
    """
    Return error response
    """
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({
            'error': message
        })
    }