// Constants for screen size and ship movement
final int SCREEN_WIDTH = 800;
final int SCREEN_HEIGHT = 600;
float SHIP_SPEED = 0.1;
float SHIP_INERTIA = 0.99;

// Ship properties
float shipX, shipY;
float shipDirection;
float shipSize = 30;
float shipSpeed;
boolean isAccelerating = false;

// Asteroid properties
int numAsteroids = 5;
ArrayList<Asteroid> asteroids;

// Bullet properties
ArrayList<Bullet> bullets;
float bulletSize = 10;
float bulletSpeed = 5;

// Particle properties
ArrayList<Particle> particles;

void settings() {
  size(SCREEN_WIDTH, SCREEN_HEIGHT);
}

void setup() {
  shipX = width / 2;
  shipY = height / 2;

  // Create asteroids
  asteroids = new ArrayList<Asteroid>();
  for (int i = 0; i < numAsteroids; i++) {
    asteroids.add(new Asteroid());
  }

  bullets = new ArrayList<Bullet>();
  particles = new ArrayList<Particle>();
}

void draw() {
  background(0);

  // Update ship position based on acceleration
  if (isAccelerating) {
    shipSpeed += SHIP_SPEED;
  } else {
    shipSpeed *= SHIP_INERTIA;
  }
  shipX += shipSpeed * cos(shipDirection);
  shipY += shipSpeed * sin(shipDirection);

  // Wrap ship around the screen
  wrapAroundShip();

  // Update asteroids
  for (int i = asteroids.size() - 1; i >= 0; i--) {
    Asteroid asteroid = asteroids.get(i);
    asteroid.update();

    // Wrap asteroids around the screen
    wrapAroundAsteroid(asteroid);

    // Check for collision with ship
    if (dist(shipX, shipY, asteroid.position.x, asteroid.position.y) < shipSize / 2 + asteroid.size / 2) {
      // Handle ship collision (e.g., game over, reduce ship health, etc.)
      // For now, let's just reset the ship's position
      shipX = width / 2;
      shipY = height / 2;
    }

    // Check for collision with bullets
    for (int j = bullets.size() - 1; j >= 0; j--) {
      Bullet bullet = bullets.get(j);
      if (dist(bullet.position.x, bullet.position.y, asteroid.position.x, asteroid.position.y) < bulletSize / 2 + asteroid.size / 2) {
        // Break the asteroid into particles
        asteroid.breakApart();
        // Remove the asteroid and bullet
        asteroids.remove(i);
        bullets.remove(j);
        break;
      }
    }
  }

  // Update bullets
  for (int i = bullets.size() - 1; i >= 0; i--) {
    Bullet bullet = bullets.get(i);
    bullet.update();

    // Check if bullet is off-screen
    if (bullet.position.x < 0 || bullet.position.x > width || bullet.position.y < 0 || bullet.position.y > height) {
      bullets.remove(i);
    }
  }

  // Update particles
  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle particle = particles.get(i);
    particle.update();
    if (particle.isDead()) {
      particles.remove(i);
    }
  }

  // Draw ship
  pushMatrix();
  translate(shipX, shipY);
  rotate(shipDirection + HALF_PI); // Add HALF_PI to rotate the ship so the tip is facing forward
  fill(255);
  beginShape();
  vertex(0, -shipSize / 2);
  fill(255, 0, 0);
  vertex(-shipSize / 4, shipSize / 2);
  fill(255);
  vertex(0, shipSize / 4);
  vertex(shipSize / 4, shipSize / 2);
  endShape(CLOSE);
  popMatrix();

  // Draw asteroids
  for (Asteroid asteroid : asteroids) {
    asteroid.display();
  }

  // Draw bullets
  fill(0, 255, 0);
  for (Bullet bullet : bullets) {
    ellipse(bullet.position.x, bullet.position.y, bulletSize, bulletSize);
  }

  // Draw particles
  for (Particle particle : particles) {
    particle.display();
  }
}

void keyPressed() {
  // Rotate ship left or right
  if (key == 'a' || key == 'A') {
    shipDirection -= 0.1;
  } else if (key == 'd' || key == 'D') {
    shipDirection += 0.1;
  }

  // Accelerate ship
  if (key == 'w' || key == 'W') {
    isAccelerating = true;
  }

  // Fire bullet from the front of the ship
  if (key == ' ') {
    float bulletX = shipX + (shipSize / 2) * cos(shipDirection); // Calculate bullet position relative to ship's front
    float bulletY = shipY + (shipSize / 2) * sin(shipDirection); // Calculate bullet position relative to ship's front
    bullets.add(new Bullet(bulletX, bulletY, shipDirection));
  }
}

void keyReleased() {
  // Stop ship acceleration
  if (key == 'w' || key == 'W') {
    isAccelerating = false;
  }
}

void wrapAroundShip() {
  if (shipX < 0) {
    shipX = width;
  } else if (shipX > width) {
    shipX = 0;
  }

  if (shipY < 0) {
    shipY = height;
  } else if (shipY > height) {
    shipY = 0;
  }
}

void wrapAroundAsteroid(Asteroid asteroid) {
  if (asteroid.position.x < 0) {
    asteroid.position.x = width;
  } else if (asteroid.position.x > width) {
    asteroid.position.x = 0;
  }

  if (asteroid.position.y < 0) {
    asteroid.position.y = height;
  } else if (asteroid.position.y > height) {
    asteroid.position.y = 0;
  }
}

class Asteroid {
  PVector position;
  PVector velocity;
  float size;

  Asteroid() {
    size = random(30, 50);
    float spawnX = random(width);
    float spawnY = random(height);
    position = new PVector(spawnX, spawnY);
    float angle = random(TWO_PI);
    float speed = random(1, 3);
    velocity = PVector.fromAngle(angle).mult(speed);
  }

  void update() {
    position.add(velocity);
  }

  void display() {
    stroke(255);
    noFill();
    ellipse(position.x, position.y, size, size);
  }

  void breakApart() {
    for (int i = 0; i < 10; i++) {
      Particle particle = new Particle(position.x, position.y, size / 4);
      particles.add(particle);
    }
  }
}

class Bullet {
  PVector position;
  PVector velocity;

  Bullet(float x, float y, float direction) {
    position = new PVector(x, y);
    velocity = PVector.fromAngle(direction).mult(bulletSpeed);
  }

  void update() {
    position.add(velocity);
  }
}

class Particle {
  PVector position;
  PVector velocity;
  float size;
  int lifespan = 255;

  Particle(float x, float y, float size) {
    position = new PVector(x, y);
    velocity = PVector.random2D().mult(random(1, 5));
    this.size = size;
  }

  void update() {
    position.add(velocity);
    lifespan -= 5;
  }

  void display() {
    noStroke();
    fill(255, lifespan);
    ellipse(position.x, position.y, size, size);
  }

  boolean isDead() {
    return lifespan <= 0;
  }
}
