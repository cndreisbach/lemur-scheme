import scala.io.Source

object JasminCompiler {
  def main(args: Array[String]) {
    if (args.length < 1 || args.length > 2) {
      println("Usage: scala JasminCompiler <file.scm> [<ClassName>]")
      System.exit(0)
    }
     
    val schemeCode = Source.fromFile(args(0)).getLines.
                      toList.reduceLeft((a, b) => a + b)
    val className = if (args.length == 2)
                      args(1)
                    else
                      transformFilename(args(0))

    emitAssembly(schemeCode, className)
  }

  def emitAssembly(code: String, className: String) {
    println(".class public " + className)
    println(".super java/lang/Object")

    println("; standard initializer (calls java.lang.Object's initializer)")
    println(".method public <init>()V")
    println("  aload_0")
    println("  invokenonvirtual java/lang/Object/<init>()V")
    println("  return")
    println(".end method")
    println(".method public static main([Ljava/lang/String;)V")
    println("  .limit stack 2   ; up to two items can be pushed")
    println("  ; push System.out onto the stack")
    println("  getstatic java/lang/System/out Ljava/io/PrintStream;")
    println("  ; push a string onto the stack")
    println("  ldc \"Insert Scheme code here\"")
    println("  ; call the PrintStream.println() method.")
    println("  invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V")
    println("  return")
    println(".end method")
  }

  private def transformFilename(filename: String): String = {
    val newName = filename.substring(0, filename.indexOf('.')).
                    replaceAll("[^A-Za-z]", "")
    newName.substring(0,1).toUpperCase() + newName.substring(1)
  }
}
