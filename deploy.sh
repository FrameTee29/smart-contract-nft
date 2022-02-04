    echo "Deploying pistol gun"
    npx hardhat run ./scripts/deployPistolGun.ts --network $1

    echo "Deploying Rifle gun"
    npx hardhat run ./scripts/deployRifleGun.ts --network $1

    echo "Deploying Shotgun gun"
    npx hardhat run ./scripts/deployShotgunGun.ts --network $1

    echo "Deploying pistol bullet"
    npx hardhat run ./scripts/deployPistolBullet.ts --network $1

    echo "Deploying Rifle bullet"
    npx hardhat run ./scripts/deployRifleBullet.ts --network $1

    echo "Deploying Shotgun bullet"
    npx hardhat run ./scripts/deployShotgunBullet.ts --network $1
    
