import java.util.Arrays;
import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import scala.Tuple2;

public class WordCount {

    public static void main(String[] args) {
        String inputFile = args.length > 0 ? args[0] : "filesample.txt";
        String outputFile = args.length > 1 ? args[1] : "result";

        SparkConf conf = new SparkConf().setAppName("WordCount");
        JavaSparkContext sc = new JavaSparkContext(conf);

        long t1 = System.currentTimeMillis();

        JavaRDD<String> data = sc.textFile(inputFile)
                .flatMap(s -> Arrays.asList(s.split(" ")).iterator());

        JavaPairRDD<String, Integer> counts = data
                .mapToPair(w -> new Tuple2<>(w, 1))
                .reduceByKey(Integer::sum);

        counts.saveAsTextFile(outputFile);

        long t2 = System.currentTimeMillis();
        System.out.println("======================");
        System.out.println("time in ms : " + (t2 - t1));
        System.out.println("======================");

        sc.close();
    }
}
