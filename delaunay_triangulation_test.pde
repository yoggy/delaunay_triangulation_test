DelaunayTriangulation d;

void setup() {
  size(640, 480);

  d = new DelaunayTriangulation();

  background(0);
}

void draw() {
  background(0);
  createDelaunayTriangulation();
  d.draw();  
}

void createDelaunayTriangulation() {
  println("start createDelaunayTriangulation()");
  long st = millis();

  int n = 100;
  PVector [] v = new PVector[n];
  for (int i = 0; i < n; ++i) {
    float x = random(0, width);
    float y = random(0, height);
    v[i] = new PVector(x, y);
  }   

  d.process(v);

  long et = millis();
  println("finish createDelaunayTriangulation() : n=" + n + ", prosess time=" + (et - st) / 1000.0f);
}
