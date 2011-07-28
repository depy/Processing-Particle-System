import ddf.minim.*;
import ddf.minim.analysis.*;
import processing.opengl.*;

Minim minim;
AudioPlayer song;
FFT fft;

int num_particles=0;

class Particle
{
  float ttl = 0.8;
  PVector loc;
  PVector vel;
  PVector acc;
  float r;
  float timer;
  float strokeAlpha = 100;
  float fillAlpha = 200;
  color strokeColor = 250;
  color fillColor = color(250.0, 150.0, 0.0);
  float deg;
  float br;
  
  Particle(PVector l, float b)
  {

    loc=l.get();
    br = b;
    float angle = atan2(width/2-loc.x, height/2-loc.y);
    deg = angle * (180/3.14) + 180;
    vel = new PVector((loc.x-width/2)/5+br*5, (loc.y-height/2)/5+br*5, 10);
    acc = new PVector(-1 * vel.x/100, -1 * vel.y/100, -2.0);
    r = 12.0;
    timer = ttl;     
  }
    
  void run()
  {
    update();
    render();
  }
  
  void update()
  {
    vel.add(acc);
    loc.add(vel);
    timer -= (1/frameRate);
    fillAlpha = 250-(abs(timer/ttl - 0.9)*1000)/2;
  }
  
  void render()
  {
    pushMatrix();
    translate(loc.x, loc.y, loc.z);
    
    ellipseMode(CENTER);
    
    fillColor = color(deg, 360, (int)(Math.log10(br*20)*200));

    stroke(strokeColor, strokeAlpha);
    fill(fillColor, fillAlpha);
    ellipse(0, 0, r, r);
    popMatrix();
  }
  
  boolean dead()
  {
    if(timer <= 0.01)
    {
      return true;
    }
    else
    {
      return false;
    }
  }

};


class ParticleSystem
{
  ArrayList particles;
  PVector origin;
  int count = 1;
  
  ParticleSystem(int num, int c, PVector v)
  {
    particles = new ArrayList();
    origin = v.get();
    count = c;
    
    for(int i=0; i<num; i++)
    {
      particles.add(new Particle(origin, 0));
    }
  }
  
  void run()
  {
    for(int i=particles.size()-1; i>=0; i--)
    {
      Particle p = (Particle)particles.get(i);
      p.run();
      if(p.dead())
      {
        particles.remove(i);
        num_particles--;
      }
    }
  }
  
  void addParticle() 
  {
    for(int i=0; i<count; i++)
    {
      particles.add(new Particle(origin, 0));
    }
  }
  
  void addParticle(float x, float y, float a, float b)
  {
    for(int i=0; i<count; i++)
    {
      num_particles++;
      particles.add(new Particle(new PVector(x+sin(a)*30,y+cos(a)*30), b));
    }
  }
    
  void addParticle(Particle p)
  {
    for(int i=0; i<count; i++)
    {
      particles.add(p);
    }
  }
    
  boolean dead() 
  {
    if (particles.isEmpty()) 
    {
      return true;
    } 
    else 
    {
      return false;
    }
  }

};

ParticleSystem ps; 

void setup()
{
  frameRate(60);
  colorMode(HSB, 360);
  size(800, 600, OPENGL);
  ps = new ParticleSystem(0, 1, new PVector(width/2, height/2));
  smooth();
  
  minim = new Minim(this);
  song = minim.loadFile("/path/to/your/file.mp3");
  song.loop();
  fft = new FFT(song.bufferSize(), song.sampleRate());
  fft.window(FFT.HAMMING);
  fft.logAverages(22, 6);
  print(fft.avgSize()+" ");
}

void draw()
{
  fft.forward(song.mix);
  
  background(0,0,0);
  translate(0,0,0);
  pushMatrix();
  
  print(num_particles+ "\n");
  ps.run();

  if(frameCount%5==0)
  {
    
    for(int i=0; i < fft.avgSize(); i++)
    {
        ps.addParticle(ps.origin.x, ps.origin.y, ((i*(360/fft.avgSize()))*3.14)/180, (float)Math.log10(fft.getAvg(i)));

    }
  }
  popMatrix();
}
