import 'package:flutter_test/flutter_test.dart';
import 'package:tamweel_calc/core/engine/eligibility.dart';
import 'package:tamweel_calc/core/engine/regulations.dart';
void main(){ test('v7 ksa',(){
 for (final b in DbrBase.values){
 final r=EligibilityEngine.calculate(rules: RegulationRules.forCountry(Country.ksa),loanType: LoanType.personal,status: EmploymentStatus.employed,basic:10000,housing:2500,other:0,existingEmis:0,cardLimits:0,annualRate:5,tenorMonths:60,bankDbrBase:b);
 print('$b cap=${r.capPct} base=${r.dbrBaseIncome} emi=${r.maxTotalEmi} pv=${r.maxFinancing} f=${r.limitingFactor}');}
});}
