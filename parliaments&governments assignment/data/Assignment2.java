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
        String newUrl = url + "?currentSchema=parlgov";
        try {
            connection = DriverManager.getConnection(newUrl, username, password);
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
        
        // the query
        String query =
        //final result
        "select countryElection.election2 as electionID, countryCabinet.cID as cabinetID "
           // select cabinet id and its start_date election natural join cabinet
        + "from (select cabinet.id as cID, start_date "
        +          "from election join cabinet on election.id = cabinet.election_id ) countryCabinet, "
                    // select from election1 X election2
        +           "(select election2.eID as election2, election2.e_date as election2_date, election1.e_date as election1_date "
                                // all elections within this country
        +               " from (select election.id as eID, e_type, e_date "
        +                       "from election join country on election.country_id = country.id "
        +                       "where country.name = ? "
        +                       " ) election1, "
                                // all elections within this country
        +                       "(select election.id as eID, e_type, e_date "
        +                       " from election join country on election.country_id = country.id "
        +                       " where country.name = ? "
        +                       " ) election2 "
        +               " where (election1.e_type = election2.e_type and election2.e_date < election1.e_date "
                        // election1.e_date is the smallest date of same election type after election2
        +                "and election1.e_date = (select min(election.e_date) "
                            // all elections within this country
        +                   "from (select e_type, e_date from election join country on election.country_id = country.id where country.name = ?) election "
                            // of same type election but larger date
        +                   "where election.e_type = election2.e_type and election.e_date > election2.e_date)) "
                            // in case an election is the most recent among this election type
                            // election2.e_date is the largest date of same election type
        +                   "or (election2.e_date = (select max(e_date) "
                            // all elections within this country
        +                   "from (select e_type, e_date from election join country on election.country_id = country.id where country.name = ?) election_ "
        +                   "where election_.e_type = election2.e_type and election2.e_date < election_.e_date)) "
        +             " ) countryElection "
            // finally, select those cabinet between the timeline inclusive
        +  "where election1_date >= countryCabinet.start_date and countryCabinet.start_date >= election2_date "
          // order
        + "order by extract(year from countryElection.election2_date) desc, countryCabinet.start_date asc; ";
        
        try {
            // execute query
            PreparedStatement preparedStatement = connection.prepareStatement(query);
            preparedStatement.setString(1, countryName);
            preparedStatement.setString(2, countryName);
            preparedStatement.setString(3, countryName);
            preparedStatement.setString(4, countryName);
            ResultSet rs = preparedStatement.executeQuery();
            // extract column value
            for (int i = 0; rs.next(); i++) {
                elections.add(i, rs.getInt("electionID"));
                cabinets.add(i, rs.getInt("cabinetID"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("SQL Exception." +
                               "<Message>: " + e.getMessage());
        }
        ElectionCabinetResult electionCabinetResult = new ElectionCabinetResult(elections, cabinets);
        return electionCabinetResult;
    }
    
    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        // initialize the result
        List<Integer> result = new ArrayList<>();
        // the query
        String query =
        "SELECT P1.description as description1, P1.comment as comment1, P2.id as presidentID, P2.description as description2, P2.comment as comment2 "
        + "FROM politician_president P1, politician_president P2 "
        + "WHERE P1.id = ? and P1.id < P2.id;";
        try {
            // execute query
            PreparedStatement preparedStatement = connection.prepareStatement(query);
            preparedStatement.setInt(1, politicianName);
            ResultSet rs = preparedStatement.executeQuery();
            // extract column value
            while (rs.next()) {
                String descirptAndComment1 =
                rs.getString("description1") + " " + rs.getString("comment1");
                String descriptAndComment2 =
                rs.getString("description2") + " " + rs.getString("comment2");
                double similarity = similarity(descirptAndComment1, descriptAndComment2);
                if (similarity >= threshold) {
                    result.add(rs.getInt("presidentID"));
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("SQL Exception." +
                               "<Message>: " + e.getMessage());
        }
        return result;
    }
    
    public static void main(String[] args) {
        try {
            Assignment2 a2 = new Assignment2();
            a2.connectDB("jdbc:postgresql://localhost:5432/csc343h-dangyuan", "dangyuan", "");
            System.out.println(a2.electionSequence("France"));
            System.out.println(a2.findSimilarPoliticians(9, (float) 0.0));
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        System.out.println("Hello");
        String namee = "cand";
        char[] name = namee.toCharArray();
        System.out.println(name);
    }
}
