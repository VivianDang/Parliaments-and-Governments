import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
// import java.util.ArrayList;
// import java.util.Map;
// import java.util.HashMap;
// import java.util.Set;
// import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {

  public Assignment2() throws ClassNotFoundException {

    Class.forName("org.postgresql.Driver");
  }

  @Override
  public boolean connectDB(String url, String username, String password) {
    // String newUrl = url + "?currentSchema=parlgov";
    try {
      Properties props = new Properties();
      props.setProperty("user", username);
      props.setProperty("password", password);
      props.setProperty("currentSchema", "parlgov");
      connection = DriverManager.getConnection(url, props);
      // connection = DriverManager.getConnection(newUrl, username, password);
      // set search path
      // String query = "SET search_path to parlgov;";
      // execute query
      // PreparedStatement preparedStatement = connection.prepareStatement(query);
      // preparedStatement.executeQuery();
    } catch (SQLException e) {
      return false;
    }
    return true;
  }

  @Override
  public boolean disconnectDB() {

    try {
      connection.close();
    } catch (SQLException e) {
      return false;
    }
    return true;
  }

  @Override
  public ElectionCabinetResult electionSequence(String countryName) {
    // initialize the result
    List<Integer> elections = new ArrayList<>();
    List<Integer> cabinets = new ArrayList<>();
    ElectionCabinetResult electionCabinetResult = new ElectionCabinetResult(elections, cabinets);
    char[] name = countryName.toCharArray();

    // the query
    String query =
        "select countryElection.election2, countryCabinet.cID "
            + "from (select cabinet.id as cID, start_date "
            +          "from election join cabinet on election.id = cabinet.election_id ) countryCabinet, "
            +           "(select election2.eID as election2, election2.e_date as election2_date, election1.e_date as election1_date "
            +               " from (select election.id as eID, e_type, e_date "
            +                       "from election join country on election.country_id = country.id "
            +                       "where country.name = "
            +                           name
            +                       " ) election1, "
            +                       "(select election.id as eID, e_type, e_date "
            +                       " from election join country on election.country_id = country.id "
            +                       " where country.name = "
            +                           name
            +                       " ) election2 "
            +               " where election1.e_type = election2.e_type and election1.e_date > election2.e_date"
                + "order by extract(year from countryElection.e_date) desc"
            +             " ) countryElection"
            +  "where election1_date >= countryCabinet.start_date and countryCabinet.start_date >= election2_date"
                ;

    try {
      // execute query
      PreparedStatement preparedStatement = connection.prepareStatement(query);
      ResultSet rs = preparedStatement.executeQuery();
      // extract column value
      for (int i = 0; rs.next(); i++) {
        electionCabinetResult.elections.set(i, rs.getInt("electionID"));
        electionCabinetResult.cabinets.set(i, rs.getInt("cabinetID"));
      }

    } catch (SQLException e) {
      //            e.printStackTrace();
      //            System.err.println("SQL Exception." +
      //                    "<Message>: " + e.getMessage());
    }

    return electionCabinetResult;
  }

  @Override
  public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
    // initialize the result
    List<Integer> result = new ArrayList<>();
    // the query
    String query =
        "SELECT P1.description as description1, P1.comment as comment1, P2.id, P2.description as description2, P2.comment as comment 2 "
            + "FROM politician_president P1, politician_president P2 "
            + "WHERE P1.id = politicianName;";
    try {
      // execute query
      PreparedStatement preparedStatement = connection.prepareStatement(query);
      ResultSet rs = preparedStatement.executeQuery();
      // extract column value
      while (rs.next()) {
        String descirptAndComment1 =
            rs.getString("P1.description") + " " + rs.getString("P1.comment");
        String descriptAndComment2 =
            rs.getString("P2.description") + " " + rs.getString("P2.comment");
        double similarity = similarity(descirptAndComment1, descriptAndComment2);
        if (similarity >= threshold) {
          result.add(rs.getInt("P2.id"));
        }
      }

    } catch (SQLException e) {
      //            e.printStackTrace();
      //            System.err.println("SQL Exception." +
      //                    "<Message>: " + e.getMessage());
    }
    return result;
  }

  public static void main(String[] args) {
    try {
      Assignment2 a2 = new Assignment2();
      a2.connectDB("jdbc:postgresql://localhost:5432/csc343h-dangyuan", "dangyuan", "");
      System.out.println(a2.electionSequence("France"));
      System.out.println(a2.findSimilarPoliticians(9, (float) 0));
    } catch (ClassNotFoundException e) {
      e.printStackTrace();
    }
    System.out.println("Hello");
    String namee = "cand";
    char[] name = namee.toCharArray();
    System.out.println(name);
  }
}
