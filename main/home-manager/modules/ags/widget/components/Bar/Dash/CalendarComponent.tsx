const rows = Array(5);
const cols = Array(7);

const Day = ({ day }: { day: number }) => <box>{day}</box>;
//if firstdayofmonth is 0 then do nothing
//else get number of days to previous sunday
//j

export default function CalendarComponent() {
  const currentDate = new Date();

  const firstDayOfMonth = new Date(
    currentDate.getFullYear(),
    currentDate.getMonth(),
    1,
  );
  const lastDayOfMonth = new Date(
    currentDate.getFullYear(),
    currentDate.getMonth() + 1,
    0,
  );

  const lastDayOfPreviousMonth = new Date(
    currentDate.getFullYear(),
    currentDate.getMonth(),
    0,
  );

  const lastSundayOfPreviousMonth = new Date(lastDayOfPreviousMonth);
  lastSundayOfPreviousMonth.setDate(
    lastDayOfPreviousMonth.getDate() - lastDayOfPreviousMonth.getDay(),
  );

  const differenceToLastMonthsSunday = Math.floor(
    (firstDayOfMonth.getTime() - lastSundayOfPreviousMonth.getTime()) /
      (1000 * 60 * 60 * 24),
  );

  return <box></box>;
}
