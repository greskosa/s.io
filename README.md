# SeaBattle PVP 1.0

## Setup & Launch Instructions

### Prerequisites
- Node.js installed on your system
- npm package manager

### Configuration
1. Provide IP address in the `config.json` file. You can use either:
   - Public IP address (ensure your firewall allows external connections)
   - Internal IP address (for running within your private network)

   Example configuration:
   ```json
   {
     "ip": "192.168.0.101",
     "port": 8080, // it will be used only by socket connection
     "protocol": "http"
   }
   ```

### Installation & Build
1. Install dependencies:
   ```
   npm install
   ```

2. Build the UI by compiling CoffeeScript files to JavaScript:
   ```
   npm run build
   ```

### Starting the Application
1. Start the Node.js server:
   ```
   npm run start
   ```

2. Host `index.hml` page. You can use Live Server Extension for your IDE. By default it uses port `5500`. Open your browser and navigate to:
   ```
   http://YOUR_IP:5500
   ```

### Playing the Game
1. Create a new game room or join an existing one
2. Wait for another player to connect
3. Place your ships and start the battle

## Troubleshooting
If you experience connection issues, verify that:
- The server is running
- Your IP address is correctly configured
- Port is open and not blocked by firewall

Enjoy the game!
