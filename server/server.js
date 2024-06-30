// Import the WebSocket library
const WebSocket = require('ws');

// Create a new WebSocket server listening on port 8080
const wss = new WebSocket.Server({ port: 8080 });

// List of stock symbols
const stocks = ['AAPL', 'GOOGL', 'MSFT', 'AMZN', 'TSLA'];

// Function to generate a random stock price
const getRandomPrice = () => (100 + Math.random() * 1000).toFixed(2);

// Event listener for new connections to the WebSocket server
wss.on('connection', ws => {
  console.log('New client connected');

  // Function to send stock price updates to the client
  const sendStockUpdates = () => {
    const updates = stocks.map(symbol => ({
      symbol,
      price: getRandomPrice()
    }));
    console.log('Sending updates:', JSON.stringify(updates));
    ws.send(JSON.stringify(updates));
  };

  // Set an interval to send updates every second (1000 ms)
  const interval = setInterval(sendStockUpdates, 1000);

  // Event listener for when the client disconnects
  ws.on('close', () => {
    console.log('Client disconnected');
    clearInterval(interval);
  });

  // Event listener for errors
  ws.on('error', error => {
    console.error('WebSocket error:', error);
    clearInterval(interval);
  });
});

// Log message to indicate the server has started
console.log('Server started on ws://localhost:8080');
