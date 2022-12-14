import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

public class Maze
{
  private Square[][] grid;
  private Square start;
  private Square end;
  private Square currState;
  public int lMax;
  public int cMax;
  public char[] order = {'N', 'E', 'S', 'W'}; //Shift order in the grid during solving in cardinals
  public Minoutar[] minoutars;
  public Player player;
  public Square[] minPos;
  public Stor stor;
  public Gun gun;
  public Square gunPos;

  /*
  * Constructor with no file
  * lRange: Number of lines in the maze
  * cRange: Number of columns in the maze
  * start: The starting square of the maze
  * end: the ending square of the maze
  */
  public Maze(int[][] maze, Square start, Square end, Square[] minPos, Square gunPos, Stor stor) {
    //Set max values
    this.lMax = maze.length;
    this.cMax = maze[0].length;
    this.minPos = minPos;

    this.stor = stor;

    //Init grid
    this.grid = new Square[lMax][cMax];
    for (int l = 0; l < lMax; l++) {
      for (int c = 0; c < cMax; c++) {
        this.grid[l][c] = new Square(l,c, maze[l][c] == 0);
      }
    }

    this.assignMazeToGridSquares();

    //Create start and end MazeState objects contaning the start and end squares (stated)
    this.end = end;
    this.start = start;

    this.currState = this.getStart();
    //At this point, the grid is and stay the inital Maze unsolved.

    player = new Player(start.c, start.l, this);

    minoutars = new Minoutar[minPos.length];
    int i = 0;
    for (Square s : minPos) {
      minoutars[i] = new Minoutar(s.c, s.l, this, player);
      i++;
    }
    this.gunPos = gunPos;
    gun = new Gun(gunPos.c, gunPos.l, this);
  }

  public void keyPressed() {
    player.keyPressed();
  }

  public void update() {
    draw();

    player.update();
    gun.update();

    for (Minoutar m : minoutars) {
      m.update();
    }

    player.moved = false;
  }

  public boolean validPos(int x, int y) {
    return x >= 0 && x < cMax && y >= 0 && y < lMax && !grid[y][x].isWall();
  }

  public Maze(Square[][] grid, Square start, Square end, Square currState, int lMax, int cMax) {
    this.grid = grid;
    this.start = start;
    this.end = end;
    this.currState = currState;
    this.lMax = lMax;
    this.cMax = cMax;
  }

  /**
   * Resets the maze
  */
  public void reset() {
    this.currState = this.getStart();
    player = new Player(start.c, start.l, this);

    minoutars = new Minoutar[minPos.length];
    int i = 0;
    for (Square s : minPos) {
      minoutars[i] = new Minoutar(s.c, s.l, this, player);
      i++;
    }

    gun = new Gun(gunPos.c, gunPos.l, this);

    transitionIn.reset();
  }

  /*
  * Retuns the starting Square
  */
  public Square getStart() {
    return start;
  }

  /*
  * Sets the starting Square for the attribute and the grid
  * start: The square to set as starting square
  */
  public void setStart(Square start) {
    this.start = start;
    this.grid[start.getLine()][start.getCol()] = start;
  }

  /*
  * Returns the ending Square
  */
  public Square getEnd() {
    return end;
  }

  /*
  * Sets the ending Square for the attribute and the grid
  * end: The square to set as ending square
  */
  public void setEnd(Square end) {
    this.end = end;
    this.grid[end.getLine()][end.getCol()] = end;
  }

  /*
  * Sets a wall in the maze
  * l: Line position of the wall
  * c: Column position of the wall
  */
  public void setMazeWall(int l, int c) {
    this.grid[l][c].setWall();
  }

  public Square getCurrState() {
    return this.currState;
  }

  public void setCurrState(Square c) {
    this.currState = c;
  }

  public void setNextState(Square c) {
    this.grid[this.currState.getLine()][this.currState.getCol()].setAttribute("*");
    this.currState = c;
  }

  public void assignMazeToGridSquares() {
    for (int i = 0; i < this.lMax; i++)
      	{
      for (int j = 0; j < this.cMax; j++) {
        this.grid[i][j].assignMaze(this);
      }
    }
  }

  /*
  * Initiates the maze
  */
  public void initMaze() {
    //Init grid
    this.resetGrid();

    this.currState = this.getStart();
  }

  public void resetGrid() {
    for (int i = 0; i < this.lMax; i++) {
      for (int j = 0; j < this.cMax; j++) {
        if (this.grid[i][j].getAttribute() == "*")
          this.grid[i][j].setAttribute(" ");
      }
    }
  }

  /*
  * Sets a new shift order
  * newOrder: 4 entries char array, each char (in caps) means a shift direction, for example : ['N', 'S', 'W', 'E'] will shifts North -> South -> West -> East.
  */
  public void setOrder(char[] newOrder) {
    if (newOrder.length == 4) {
      this.order = newOrder;
    }
  }

  /*
  * Resets the default order North -> East -> South -> West (Clockwise)
  */
  public void resetOrder() {
    char[] o = {'N', 'E', 'S', 'W'};
    this.order = o;
  }

  /*
  * Returns the maze grid
  */
  public Square[][] getGrid() {
    return grid;
  }

  public Maze clone() {
    return new Maze(this.grid, this.start, this.end, this.currState, this.lMax, this.cMax);
  }

  /*
   * Get the maze in a unicode box draw format
   */
  public String toString() {
    String res = "   ";
    String res_under = "";
    Square temp = null;
    Square templineunder = null;
    Square tempnextcol = null;
    Square tempdiag = null;

    //Columns numbers
    for (int i = 0; i < cMax; i++) {
      if (i < 10) res += "  " + i + " "; else res += "  " + i;
    }
    res += "\n   ???";

    //First row : Maze top edge
    for (int i = 1; i < this.cMax; i++) {
      temp = this.grid[0][i - 1];
      tempnextcol = this.grid[0][i];
      if (temp.isWall()) res += "????????????"; else if (tempnextcol.isWall()) res +=
        "????????????"; else res += "????????????";
    }
    res += "????????????\n";

    //Browse all squares
    // res = the line containing the square states
    // res_under = the graphics under the squares line with the corner unicode characters
    // contatenation of res + res_under at each line
    //Example :
    //		???   ???   ???   ??? <- res
    //		??????????????????????????????????????? <- res_under
    //		    ???   ???     <- res
    //		    ???????????????     <- res_under
    //		etc...
    for (int l = 0; l < this.lMax; l++) {
      res_under = "";
      for (int c = 0; c < this.cMax; c++) {
        //Get Squares
        temp = this.grid[l][c]; // = A -> Current square
        tempnextcol = temp.getEast(); // = B -> Square at the right of temp
        templineunder = temp.getSouth(); // = C -> Square below temp
        if (l < this.lMax - 1 && c < this.cMax - 1) tempdiag =
          templineunder.getEast(); // = D -> Square in the temp lower right-hand diagonal

        if (c == 0) { //First colomn of current line l
          if (l < 10) res += l + "  ???"; else res += l + " ???";

          if (templineunder != null) {
            if (temp.isWall() || templineunder.isWall()) res_under +=
              "   ???"; else res_under += "   ???";
          }
        }

        if (temp.isWall()) {
          res += "   ";
          res_under += "?????????";
        } else {
          if (
            temp.getLine() == this.currState.getLine() &&
            temp.getCol() == this.currState.getCol()
          ) res += " o "; else if (
            temp.getLine() == this.start.getLine() &&
            temp.getCol() == this.start.getCol()
          ) res += " S "; else if (
            temp.getLine() == this.end.getLine() &&
            temp.getCol() == this.end.getCol()
          ) res += " E "; else res += " " + temp.getAttribute() + " ";

          if (l < this.lMax - 1) {
            if (templineunder.isWall()) res_under += "?????????"; else res_under +=
              "   ";
          }
        }

        //Maze right edge
        if (c == this.cMax - 1) {
          res += "???";
          if (temp != null && templineunder != null) {
            if (temp.isWall() || templineunder.isWall()) res_under +=
              "???"; else res_under += "???";
          }
        } else {
          //Squares corners.
          // two cases : wall square or not
          if (temp.isWall()) {
            res += "???";
            if (
              templineunder != null && tempdiag != null && tempnextcol != null
            ) {
              //"???" = (B + D).(C + D) -> The most reccurent corner to write
              if (
                (tempnextcol.isWall() || tempdiag.isWall()) &&
                (templineunder.isWall() || tempdiag.isWall())
              ) res_under += "???"; else {
                if (
                  !templineunder.isWall() &&
                  !tempdiag.isWall() &&
                  !tempnextcol.isWall()
                ) res_under += "???"; else if ( //Wall on top left only
                  !templineunder.isWall() &&
                  !tempdiag.isWall() &&
                  tempnextcol.isWall()
                ) res_under += "???"; else if ( // Walls on top
                  templineunder.isWall() &&
                  !tempdiag.isWall() &&
                  !tempnextcol.isWall()
                ) res_under += "???"; // Walls on left
              }
            }
          } else {
            if (tempnextcol != null) {
              if (tempnextcol.isWall()) res += "???"; else res += " ";

              if (templineunder != null && tempdiag != null) {
                //"???" = (C).(D) -> The most reccurent corner to write
                if (templineunder.isWall() && tempnextcol.isWall()) res_under +=
                  "???"; else {
                  if (
                    !templineunder.isWall() &&
                    !tempdiag.isWall() &&
                    !tempnextcol.isWall()
                  ) res_under += " "; else if ( //No wall
                    !templineunder.isWall() &&
                    tempdiag.isWall() &&
                    !tempnextcol.isWall()
                  ) res_under += "???"; else if ( //Wall on right below
                    templineunder.isWall() &&
                    !tempdiag.isWall() &&
                    !tempnextcol.isWall()
                  ) res_under += "???"; else if ( //Wall on left below
                    !templineunder.isWall() &&
                    !tempdiag.isWall() &&
                    tempnextcol.isWall()
                  ) res_under += "???"; else if ( //Wall on top right
                    !templineunder.isWall() &&
                    tempdiag.isWall() &&
                    tempnextcol.isWall()
                  ) res_under += "???"; else if ( //Walls on right
                    templineunder.isWall() &&
                    tempdiag.isWall() &&
                    !tempnextcol.isWall()
                  ) res_under += "???"; //Walls below
                }
              }
            }
          }
        }
      } //<- for each column
      if (l < this.lMax - 1) res += "\n" + res_under + "\n"; //Concatenate res + res_under
      else {
        //Maze bottom edge
        res += "\n   ???";
        for (int i = 1; i < this.cMax; i++) {
          temp = this.getGrid()[l][i - 1];
          if (temp.getEast().isWall() || temp.isWall()) res +=
            "????????????"; else res += "????????????";
        }
        res += "????????????\n";
      }
    }

    /*//Affichage simple
		String res = "   ";
		for(int i = 0; i < cMax; i++)
		{
			if(i >= 9)
				res += " " + i;
			else
				res += " " + i + " ";
		}
		res += "\n";
		for(int i = 0; i < this.lMax; i++)
		{
			if(i > 9)
				res += i + " ";
			else
				res += i + "  ";

			for(int j = 0; j < this.cMax; j++)
			{
				if(this.getGrid()[i][j].getAttribute() != "" && !this.getGrid()[i][j].isWall())
					res += "[" + this.getGrid()[i][j].getAttribute() + "]";
				else
					res += "[???]";
			}
			res += "\n";
		}*/
    return res;
  }

  public void draw() {
    push();

    fill(0);
    for (int x = 0; x < cMax; x++) {
      for (int y = 0; y < lMax; y++) {
        Square s = grid[y][x];

        if (s.isWall()) {
          square(x * Settings.STEP, y * Settings.STEP, Settings.STEP);
        }
      }
    }

    // Fill in the start square with the color green
    fill(0, 255, 0);
    square(start.getCol() * Settings.STEP, start.getLine() * Settings.STEP, Settings.STEP);

    fill(0, 0, 255);
    square(end.getCol() * Settings.STEP, end.getLine() * Settings.STEP, Settings.STEP);

    pop();
  }
}
